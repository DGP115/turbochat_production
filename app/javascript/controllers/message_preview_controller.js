import { Controller } from "@hotwired/stimulus"

/**
 * This controller is responsible for displaying the message attachment preview(s)
 */

export default class extends Controller {
  connect() {}

  /** To create the preview panel displayed above the message input.
   * This panel displays the files are are/will be uploaded as part of the chat message
  */
  preview() {

    this.clearPreviews();

    /** Loop through the files that are being attached */
    for (let i = 0; i < this.targets.element.files.length; i++) {
      let file = this.targets.element.files[i];
      const reader = new FileReader();
      this.createAndDisplayFilePreviewElements(file, reader);
    }

    this.toggleVisibility();
  }

  /**
   * Toggle the visibility of the previous div
   */
  toggleVisibility () {
    let preview = document.getElementById("attachment-previews");
    preview.classList.toggle("d-none");
  }

  /** Creates and displays the preview elements for the attached file.
    * This is used to display a preview of teh file in the message preview
    * @param {*} file - The file to be previewed
    * @param {*} reader - The FileReader object
    */
  createAndDisplayFilePreviewElements(file, reader) {
    reader.onload = () => {
      let element = this.constructPreviews(file, reader);

      element.src = reader.result;
      element.setAttribute("href", reader.result);
      element.setAttribute("target", "_blank");
      element.classList.add("attachment-preview");

      document.getElementById("attachment-previews").appendChild(element);
    };
    reader.readAsDataURL(file);
  }

  /** Constructs the preview element for the given file.
   * The file preview element is part of the display of the message preview.
   * Supported file types include:
   *  - audio:  mpeg, mp3, wav
   *  - video:  mp4, quicktime
   *  - image:  jpg, png, gif
   *  - default: anything else
   * @param {*} file - The file to be previewed
   * @param {*} reader - The FileReader object
   * @returns {HTMLElement} - The element to be added to the DOM
   */
  constructPreviews(file, reader) {
    let element;
    let cancelFunction = (e) => this.removePreview(e);
    switch (file.type) {
      case "image/jpeg":
      case "image/png":
      case "image/gif":
        element = this.createImageElement(cancelFunction, reader);
        break;
      case "audio/mpeg":
      case "audio/mp3":
      case "audio/wav":
        element = this.createAudioElement(cancelFunction, reader);
        break;
      case "video/mp4":
      case "video/quicktime":
        element = this.createVideoElement(cancelFunction, reader);
        break;
      default:
        element = this.createDefaultElement(cancelFunction, reader);
    }
    element.dataset.filename = file.name;
    return element;
  }

  /** Create an image preview element, for images of type:  jpg, png, or gif
   * @param {*} cancelFunction - The function called when the cancel button is clicked
   * @param {*} reader - The FileReader object
   * @returns {HTMLElement} - The element to be added to the DOM
  */
  createImageElement(cancelFunction, reader) {
      let cancelUploadButton;
      let element;
      const image = document.createElement("img");
      /** The preview of the file will be the file's data [reader.result] shown as a background */
      image.setAttribute("style", "background-image: url(" + reader.result + ")");

      /** Set the CSS class of the image preview */
      image.classList.add("preview-image");

      /**  Wrap the element in a <div> with the given class  */
      element = document.createElement("div");
      element.classList.add("attachment-image-container", "file-removal");
      element.appendChild(image);

      /**  Create cancel button - a Bootstrap icon - and append it to the parent element (the div)*/
      cancelUploadButton = document.createElement("i");
      cancelUploadButton.classList.add(
        "bi",
        "bi-x-circle-fill",
        "cancel-upload-button"
      );

      /** Set the cancelbutton to call cancelFunction on the click event */
      cancelUploadButton.onclick = cancelFunction;
      element.appendChild(cancelUploadButton);
      return element;
  }

  /** Create an audio preview element, for files of type: mp3, wav
   * @param {*} cancelFunction - The function called when the cancel button is clicked
   * @param {*} reader - The FileReader object
   * @returns {HTMLElement} - The element to be added to the DOM
  */
    createAudioElement(cancelFunction, reader) {
      let cancelUploadButton;
      let element;
      element = document.createElement("i");

      /**  Wrap the element in a <div> with the given class
       *   Since there is no way to preview an audio file, use style "audio-preview-icon"
      */
      element.classList.add("bi",
                            "bi-file-earmark-music-fill",
                            "audio-preview-icon",
                            "file-removal");

      /**  Create cancel button - a Bootstrap icon - and append it to the parent element (the div)*/
      cancelUploadButton = document.createElement("i");
      cancelUploadButton.classList.add("bi",
                                       "bi-x-circle-fill",
                                       "cancel-upload-button");

      /** Set the cancelbutton to call cancelFunction on the click event */
      cancelUploadButton.onclick = cancelFunction;
      element.appendChild(cancelUploadButton);
      return element;
  }

  /** Create a video preview element, for files of type: mp4, quicktime
   * @param {*} cancelFunction - The function called when the cancel button is clicked
   * @param {*} reader - The FileReader object
   * @returns {HTMLElement} - The element to be added to the DOM
  */
    createVideoElement(cancelFunction, reader) {
      let cancelUploadButton;
      let element;
      element = document.createElement("i");

      /**  Wrap the element in a <div> with the given class
       *   To preview a vidio file, use style "vidio-preview-icon"
      */
      element.classList.add("bi",
                            "bi-file-earmark-play-fill",
                            "video-preview-icon",
                            "file-removal");

      /**  Create cancel button - a Bootstrap icon - and append it to the parent element (the div)*/
      cancelUploadButton = document.createElement("i");
      cancelUploadButton.classList.add("bi",
                                       "bi-x-circle-fill",
                                       "cancel-upload-button");

      /** Set the cancelbutton to call cancelFunction on the click event */
      cancelUploadButton.onclick = cancelFunction;
      element.appendChild(cancelUploadButton);
      return element;
  }

  /** Create an "other" file type preview element.
   * @param {*} cancelFunction - The function called when the cancel button is clicked
   * @param {*} reader - The FileReader object
   * @returns {HTMLElement} - The element to be added to the DOM
  */
    createDefaultElement(cancelFunction, reader) {
      let cancelUploadButton;
      let element;
      element = document.createElement("i");

      /**  Wrap the element in a <div> with the given class
       *   To preview a vidio file, use style "vidio-preview-icon"
      */
      element.classList.add("bi",
                            "bi-file-check-fill",
                            "file-preview-icon",
                            "file-removal");

      /**  Create cancel button - a Bootstrap icon - and append it to the parent element (the div)*/
      cancelUploadButton = document.createElement("i");
      cancelUploadButton.classList.add("bi",
                                       "bi-x-circle-fill",
                                       "cancel-upload-button");

      /** Set the cancelbutton to call cancelFunction on the click event */
      cancelUploadButton.onclick = cancelFunction;
      element.appendChild(cancelUploadButton);
      return element;
  }

  /**
   * Remove the selected preview element.
   * Uses a dataTransfer to circumvent fileList limitations
   * @param {Event} e - The event object
   */
    removePreview(event) {
      const target = event.target.parentNode.closest(".attachment-preview");
      const dataTransfer = new DataTransfer();
      let fileInput = document.getElementById("message_attachments");
      let files = fileInput.files;
      let filesArray = Array.from(files);

      filesArray = filesArray.filter((file) => {
        let filename = target.dataset.filename;
        return file.name !== filename;
      });
      target.parentNode.removeChild(target);
      filesArray.forEach((file) => dataTransfer.items.add(file));
      fileInput.files = dataTransfer.files;

      if (filesArray.length === 0){
        this.toggleVisibility();
      }
    }
    /**
     * Clear all the preview elements after submit
     */
    clearPreviews() {
      document.getElementById("attachment-previews").innerHTML = "";

      let preview = document.getElementById("attachment-previews");
      preview.classList.add("d-done");
    }

}
