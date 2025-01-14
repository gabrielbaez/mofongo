import { Controller } from "@hotwired/stimulus"
import { RhinoEditor } from "@rhinoeditor/core"
import { BasicPlugin } from "@rhinoeditor/plugin-basic"
import { CodePlugin } from "@rhinoeditor/plugin-code"
import { ImagePlugin } from "@rhinoeditor/plugin-image"
import { LinkPlugin } from "@rhinoeditor/plugin-link"
import { TablePlugin } from "@rhinoeditor/plugin-table"
import sanitizeHtml from "sanitize-html"

export default class extends Controller {
  static targets = ["editor", "input"]
  
  connect() {
    this.editor = new RhinoEditor({
      element: this.editorTarget,
      plugins: [
        new BasicPlugin(),
        new CodePlugin(),
        new ImagePlugin({
          upload: {
            url: "/blog_posts/upload_image",
            headers: {
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            }
          }
        }),
        new LinkPlugin(),
        new TablePlugin()
      ],
      placeholder: "Write your blog post here...",
      onChange: (html) => {
        // Sanitize HTML before storing
        const sanitized = sanitizeHtml(html, {
          allowedTags: sanitizeHtml.defaults.allowedTags.concat([
            'img', 'figure', 'figcaption', 'iframe'
          ]),
          allowedAttributes: {
            ...sanitizeHtml.defaults.allowedAttributes,
            '*': ['class', 'id', 'style'],
            'img': ['src', 'alt', 'title', 'width', 'height'],
            'iframe': ['src', 'width', 'height', 'frameborder', 'allow', 'allowfullscreen']
          },
          allowedStyles: {
            '*': {
              'color': [/^#(0x)?[0-9a-f]+$/i, /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/],
              'background-color': [/^#(0x)?[0-9a-f]+$/i, /^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)$/],
              'text-align': [/^left$/, /^right$/, /^center$/],
              'font-size': [/^\d+(?:px|em|%)$/]
            }
          }
        })
        this.inputTarget.value = sanitized
      }
    })
    
    // Set initial content if present
    if (this.inputTarget.value) {
      this.editor.setContent(this.inputTarget.value)
    }
  }
  
  disconnect() {
    this.editor.destroy()
  }
}
