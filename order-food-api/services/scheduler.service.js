// Cloud Scheduler calls the ML endpoints over HTTP. No SDK client is required here.
module.exports = {
  triggerMode: "http",
};
