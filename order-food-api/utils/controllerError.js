function handleControllerError(res, error, fallbackMessage = "Lỗi server") {
  console.error(error);

  if (error.status) {
    return res.status(error.status).json({ message: error.message });
  }

  return res.status(500).json({
    message: fallbackMessage,
    error: error.message,
  });
}

module.exports = handleControllerError;
