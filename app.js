const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');

// ==========================
// FIREBASE CONFIG
// ==========================

const serviceAccount = require('./firebase-key.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ==========================
// EXPRESS CONFIG
// ==========================

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.set('view engine', 'ejs');

app.use(express.static('public'));

// ==========================
// REALTIME TODO STATE
// ==========================

let currentTodos = [];
const clients = new Set();

function serializeDate(value) {
    if (!value) {
        return null;
    }

    if (typeof value.toDate === 'function') {
        return value.toDate().toISOString();
    }

    if (value instanceof Date) {
        return value.toISOString();
    }

    return value;
}

function sortTodos(todos) {
    return todos.sort((a, b) => {
        if (a.completed !== b.completed) {
            return a.completed ? 1 : -1;
        }

        return new Date(b.createdAt || 0) - new Date(a.createdAt || 0);
    });
}

function sendTodos(res) {
    res.write(`data: ${JSON.stringify(currentTodos)}\n\n`);
}

function broadcastTodos() {
    for (const client of clients) {
        sendTodos(client);
    }
}

db.collection('todos')
    .orderBy('createdAt', 'desc')
    .onSnapshot((snapshot) => {
        currentTodos = [];

        snapshot.forEach((doc) => {
            const data = doc.data();

            currentTodos.push({
                id: doc.id,
                text: data.text || '',
                completed: Boolean(data.completed),
                createdAt: serializeDate(data.createdAt),
                updatedAt: serializeDate(data.updatedAt)
            });
        });

        currentTodos = sortTodos(currentTodos);
        broadcastTodos();
    }, (error) => {
        console.log(error);
    });

function shouldReturnJson(req) {
    return req.headers.accept && req.headers.accept.includes('application/json');
}

function sendSuccess(req, res) {
    if (shouldReturnJson(req)) {
        return res.json({ ok: true });
    }

    return res.redirect('/');
}

async function toggleTodo(id) {
    const todoRef = db
        .collection('todos')
        .doc(id);

    const doc = await todoRef.get();

    if (!doc.exists) {
        return false;
    }

    const currentStatus = doc.data().completed;

    await todoRef.update({
        completed: !currentStatus,
        updatedAt: new Date()
    });

    return true;
}

// ==========================
// HOME PAGE
// ==========================

app.get('/', (req, res) => {
    res.render('index', {
        todos: currentTodos
    });
});

app.get('/events', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    clients.add(res);
    sendTodos(res);

    req.on('close', () => {
        clients.delete(res);
    });
});

// ==========================
// ADD TODO
// ==========================

app.post('/add', async (req, res) => {
    try {
        const todoText = req.body.todo;

        if (!todoText || todoText.trim() === '') {
            return sendSuccess(req, res);
        }

        await db.collection('todos').add({
            text: todoText.trim(),
            completed: false,
            createdAt: new Date(),
            updatedAt: new Date()
        });

        return sendSuccess(req, res);
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi thêm todo');
    }
});

// ==========================
// EDIT TODO
// ==========================

app.post('/edit/:id', async (req, res) => {
    try {
        const todoText = req.body.todo;

        if (!todoText || todoText.trim() === '') {
            return res.status(400).send('Nội dung todo không được để trống');
        }

        await db
            .collection('todos')
            .doc(req.params.id)
            .update({
                text: todoText.trim(),
                updatedAt: new Date()
            });

        return sendSuccess(req, res);
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi sửa todo');
    }
});

// ==========================
// COMPLETE TODO
// ==========================

app.post('/complete/:id', async (req, res) => {
    try {
        const updated = await toggleTodo(req.params.id);

        if (!updated) {
            return res.status(404).send('Todo không tồn tại');
        }

        return sendSuccess(req, res);
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi cập nhật todo');
    }
});

app.get('/complete/:id', async (req, res) => {
    try {
        const updated = await toggleTodo(req.params.id);

        if (!updated) {
            return res.status(404).send('Todo không tồn tại');
        }

        return res.redirect('/');
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi cập nhật todo');
    }
});

// ==========================
// DELETE TODO
// ==========================

app.post('/delete/:id', async (req, res) => {
    try {
        await db
            .collection('todos')
            .doc(req.params.id)
            .delete();

        return sendSuccess(req, res);
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi xóa todo');
    }
});

app.get('/delete/:id', async (req, res) => {
    try {
        await db
            .collection('todos')
            .doc(req.params.id)
            .delete();

        return res.redirect('/');
    } catch (error) {
        console.log(error);
        return res.status(500).send('Lỗi xóa todo');
    }
});

// ==========================
// SERVER
// ==========================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
