import { Controller } from "@hotwired/stimulus";
import type { ChangeEvent } from "react";

// Connects to data-controller="wa-trial"
export default class extends Controller {
  connect() {
    console.log("element", this.element);
    const currentPath = this.element.getAttribute("data-current-path");
    console.log(currentPath);
  }

  optionThing(event: Event) {
    const input = event.target as HTMLSelectElement;
    console.log(event.currentTarget);
    console.log(input.value);
    // input.style.border = "1px solid red";
  }

  colorThing(event: Event) {
    const data = event.target as HTMLInputElement;
    console.log(data.value);
  }
}
