import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    this.resetScrollWithoutThreshold(messages);
  }
  /**  On Start */
  connect() {
    console.log("Connected")
    const messages = document.getElementById("messages");
    messages.addEventListener("DOMNodeInserted", this.resetScroll);
  }

  /** On Stop  */
  disconnect() {
    console.log("Disconnected")
  /** Put delection of event listeners here */

  }

  /** Custom Function */
  resetScroll() {
    const bottomOfScroll = messages.scrollHeight - messages.clientHeight;
    const upperScrollThreshold = bottomOfScroll - 500;
    //  Scroll to bottom if not within the threshold
    if (messages.scrollTop > upperScrollThreshold){
      messages.scrollTop = messages.scrollHeight - messages.clientHeight;
//      this.resetScrollWithoutThreshold(messages);
    }

  }

  resetScrollWithoutThreshold(messages) {
    messages.scrollTop = messages.scrollHeight - messages.clientHeight;
  }
}
