FROM node:24-bookworm

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN python3 -m pip install --break-system-packages -r requirements.txt

COPY . .

ENV PYTHON_BIN=python3
ENV PORT=8080

EXPOSE 8080

CMD ["npm", "start"]
