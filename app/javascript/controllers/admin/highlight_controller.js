import hljs from "highlight.js";

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    hljs.highlightAll();
  }
}