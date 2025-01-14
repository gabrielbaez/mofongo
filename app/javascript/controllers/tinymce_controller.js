import { Controller } from "@hotwired/stimulus"
import tinymce from "tinymce"

// Connects to data-controller="tinymce"
export default class extends Controller {
  static targets = ["editor"]

  connect() {
    tinymce.init({
      target: this.editorTarget,
      plugins: 'advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen insertdatetime media table code help wordcount',
      toolbar: 'undo redo | blocks | bold italic backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help',
      height: 500,
      menubar: true,
      automatic_uploads: true,
      file_picker_types: 'image',
      file_picker_callback: (cb, value, meta) => {
        const input = document.createElement('input');
        input.setAttribute('type', 'file');
        input.setAttribute('accept', 'image/*');

        input.addEventListener('change', (e) => {
          const file = e.target.files[0];
          const formData = new FormData();
          formData.append('image', file);

          fetch('/admin/images', {
            method: 'POST',
            body: formData,
            headers: {
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            }
          })
          .then(response => response.json())
          .then(data => {
            cb(data.url, { title: file.name });
          })
          .catch(error => {
            console.error('Upload failed:', error);
          });
        });

        input.click();
      }
    });
  }

  disconnect() {
    tinymce.remove();
  }
}
