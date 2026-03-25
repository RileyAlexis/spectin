import { Controller } from "@hotwired/stimulus";

export default class extends Controller<HTMLElement> {
  connect() {
    const dataTag = document.getElementById("h6idthing");
    console.log(dataTag);
    if (dataTag) {
      dataTag.style.fontWeight = "bold";
      dataTag.style.fontSize = "29px";
    }
  }

  changeTheme(event: any) {
    const value = event?.detail?.item?.value;
    if (value !== "light" && value !== "dark") return;

    localStorage.setItem("ui.theme", value);

    const isDark = value === "dark";
    document.documentElement.classList.toggle("sl-theme-dark", isDark);
    document.body?.classList.toggle("sl-theme-dark", isDark);

    // Update variant attribute for web components
    this.updateComponentVariants(isDark);

    console.log("Theme changed:", value);
  }

  updateComponentVariants(isDark: boolean) {
    const logomark = document.querySelector("puris-logomark");
    const logotype = document.querySelector("puris-logotype");
    if (logomark) logomark.setAttribute("variant", isDark ? "white" : "black");
    if (logotype) logotype.setAttribute("variant", isDark ? "white" : "black");
  }

  doabuttonthing(event: Event) {
    console.log("button");
    const button = event.currentTarget as HTMLButtonElement | null;
    const animation: any = document.getElementById("secondAnimation");

    if (animation && button) {
      animation.addEventListener("wa-finish", () => {
        button.style.display = "none";
      });
      animation.play = true;
    }
  }

  shakey(event: Event) {
    console.log("*********", event.target);

    const button = event.currentTarget as HTMLButtonElement | null;
    const container = document.querySelector(".animation-form");
    const animation: any = container?.querySelector("wa-animation");

    if (animation && button) {
      button.setAttribute("variant", "danger");
      animation.play = true;
      setTimeout(() => {
        button.setAttribute("variant", "brand");
      }, 1000);
    }
  }

  moreButtons() {
    const dataTag = document.getElementById("h6idthing");
    if (dataTag) {
      dataTag.style.backgroundColor = "#00d37b";
    }
  }
}
