import "@hotwired/turbo-rails";
import "@shoelace-style/shoelace/dist/themes/light.css";
import "@shoelace-style/shoelace/dist/themes/dark.css";
import "../../assets/stylesheets/purisTheme-light.css";
import "@awesome.me/webawesome/dist/styles/webawesome.css";

import {
  setBasePath,
  SlButton,
  SlSelect,
  SlOption,
  SlRange,
  SlDropdown,
  SlMenu,
  SlMenuItem,
  SlIcon,
} from "@shoelace-style/shoelace";

import WaButton from "@awesome.me/webawesome/dist/components/button/button.js";
import WaIcon from "@awesome.me/webawesome/dist/components/icon/icon.js";
import WaBadge from "@awesome.me/webawesome/dist/components/badge/badge.js";
import WaTooltip from "@awesome.me/webawesome/dist/components/tooltip/tooltip.js";
import WaAnimation from "@awesome.me/webawesome/dist/components/animation/animation.js";
import WaButtonGroup from "@awesome.me/webawesome/dist/components/button-group/button-group.js";
import WaDialog from "@awesome.me/webawesome/dist/components/dialog/dialog.js";
import WaRadioGroup from "@awesome.me/webawesome/dist/components/radio-group/radio-group.js";
import WaRadio from "@awesome.me/webawesome/dist/components/radio/radio.js";
import WaColorPicker from "@awesome.me/webawesome/dist/components/color-picker/color-picker.js";
import { PurisLogoType, PurisLogoMark } from "@puris/web-components";

const elements = [
  ["wa-button", WaButton],
  ["wa-icon", WaIcon],
  ["wa-badge", WaBadge],
  ["wa-tooltip", WaTooltip],
  ["wa-animation", WaAnimation],
  ["wa-button-group", WaButtonGroup],
  ["wa-dialog", WaDialog],
  ["wa-radio-group", WaRadioGroup],
  ["wa-radio", WaRadio],
  ["wa-color-picker", WaColorPicker],
  ["puris-logomark", PurisLogoMark],
  ["puris-logotype", PurisLogoType],
];

elements.forEach(([name, constructor]) => {
  customElements.define(name, constructor);
});

setBasePath("/shoelace-assets");

import "../controllers";

import ePub from "epubjs";

window.ePub = ePub;

const applyTheme = () => {
  const savedTheme = localStorage.getItem("ui.theme") || "dark";
  const isLight = savedTheme === "light";

  document.documentElement.classList.toggle("puris-light", isLight);
  document.body?.classList.toggle("puris-light", isLight);
};

applyTheme();
document.addEventListener("turbo:load", applyTheme);
