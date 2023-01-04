import consumer from "channels/consumer"

let resetFunc;
let timer = 0;

consumer.subscriptions.create("UserStatusAppearanceChannel", {

  initialized() {
    //  Called when page initially loads
  },

  connected() {
    // Called when the subscription is ready for use on the server
    //** i.e. On Start.  Call the "online" method on the server in the ActionCable Channel */
    console.log("Connected");
    //  Declaring an anonymous function becuase:
    //    1.  We need the restFunc in our EventHandlers
    //    2.  You can't remove an EventHandler from a window without having a reference to it
    //    3.  Bydefinition an anoymous function doen't have a refeence, so we are creatign one nd
    resetFunc = () => this.resetTimer(this.uninstall);
    this.install();
    window.addEventListener("turbo:load", () => this.resetTimer());
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected");
    this.uninstall();
  },

  rejected() {
    console.log("rejected");
    this.uninstall();
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  online() {
    console.log("online");
    //  Call the method in the user_status_appearance_channel to set the user's status to online
    this.perform("online");
  },

  away() {
    console.log("away");
    //  Call the method in the user_status_appearance_channel to set the user's status to away
    this.perform("away");
  },

  offline() {
    console.log("offline");
    //  Call the method in the user_status_appearance_channel to set the user's status to offline
    this.perform("offline");
  },

  install() {
    //  To install event handlers
    console.log("Install");
    //  Remove any errant event listeners
    window.removeEventListener("load", resetFunc);
    window.removeEventListener("DOMContentLoaded", resetFunc);
    window.removeEventListener("click", resetFunc);
    window.removeEventListener("keydown", resetFunc);
    //  Add event listeners
    window.addEventListener("load", resetFunc);
    window.addEventListener("DOMContentLoaded", resetFunc);
    window.addEventListener("click", resetFunc);
    window.addEventListener("keydown", resetFunc);
    this.resetTimer();
  },

  uninstall() {
    //  To uninstall event handlers
    // 1.  Search for our 'user_status_appearance_channel' on the current page.
    // 2.  If NOT found, we have left  Room Index page (or it has yet to finish loading), so
    //     perform cleanup.
    // 3.  Else, we are still on that page, so do nothing.
    const shouldRun = document.getElementById('user_status_appearance_channel');
    if (!shouldRun) {
      clearTimeout(timer);
      this.perform("offline");
    }

  },

  resetTimer() {
    // Timer is used to define the duration of inactivity in order to assume the user is away
    this.uninstall();
    const shouldRun = document.getElementById('user_status_appearance_channel');
    if (!!shouldRun) {
      this.online();
      clearTimeout(timer);
      const timeInSeconds = 30;
      const milliseconds = 1000;
      const timeInMilliseconds = timeInSeconds * milliseconds;

      timer = setTimeout(this.away.bind(this), timeInMilliseconds);

    }
  },
});
