import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="debounce"
export default class Debounce extends Controller {
  //  These ids point to the room search field in rooms/_search_form.html.erb
  static form = document.getElementById("room_search_form");
  static input = document.getElementById("name_search");

  connect() {
    this.clearParam(Debounce.input);
  }

  // This function avoids multiple queries of the database by the rooms search field.
  // While the user is typing in the field, this function forces a wait of 500ms of no activity
  // before submitting the entry to the form to then query the databae.

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      Debounce.form.requestSubmit();
    }, 500);
  }

  clearParam(input) {
    if (input.value === "") {
      const baseURL = location.origin + location.pathname;
      window.history.pushState("", "", baseURL);
    }
  }
}
