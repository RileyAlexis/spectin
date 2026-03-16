import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="reader"
export default class extends Controller {
  static targets = [
    "stage",
    "prevButton",
    "nextButton",
    "pageStatus",
    "fontFamily",
    "fontSize",
    "fontSizeOutput",
  ];

  static values = {
    bookId: String,
    epubUrl: String,
    progressUrl: String,
  };

  connect() {
    this.book = null;
    this.rendition = null;
    this.publisherPageList = null;
    this.totalBookPages = null;
    this.bookmarks = [];
    this.lastSavedCfi = null;
    this.pendingCfi = null;
    this.resizeTimer = null;
    this.saveProgressTimer = null;
    this.keyDownHandler = this.onKeydown.bind(this);
    this.resizeHandler = this.onResize.bind(this);
    this.initialize();
  }

  disconnect() {
    window.removeEventListener("keydown", this.keyDownHandler);
    window.removeEventListener("resize", this.resizeHandler);
    if (this.resizeTimer) clearTimeout(this.resizeTimer);
    if (this.saveProgressTimer) clearTimeout(this.saveProgressTimer);
    if (this.rendition) this.rendition.destroy();
    if (this.book) this.book.destroy();
  }

  getCsrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta?.content || "";
  }

  async loadProgressFromDb() {
    if (!this.progressUrlValue) return null;

    try {
      const response = await fetch(this.progressUrlValue, {
        headers: {
          Accept: "application/json",
        },
        credentials: "same-origin",
      });

      if (!response.ok) return null;

      const data = await response.json();
      this.bookmarks = Array.isArray(data.bookmarks) ? data.bookmarks : [];
      this.lastSavedCfi = data.last_cfi || null;
      return data.last_cfi || null;
    } catch {
      return null;
    }
  }

  async saveProgressToDb({ cfi, bookmarks } = {}) {
    if (!this.progressUrlValue) return;

    const payload = {};
    if (typeof cfi === "string") payload.last_cfi = cfi;
    if (Array.isArray(bookmarks)) payload.bookmarks = bookmarks;
    if (Object.keys(payload).length === 0) return;

    try {
      await fetch(this.progressUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": this.getCsrfToken(),
        },
        credentials: "same-origin",
        body: JSON.stringify(payload),
      });

      if (payload.last_cfi) {
        this.lastSavedCfi = payload.last_cfi;
      }
    } catch {
      // Ignore transient network failures; next relocation will retry.
    }
  }

  queueSaveCfi(cfi) {
    if (!cfi || cfi === this.lastSavedCfi) return;
    this.pendingCfi = cfi;
    if (this.saveProgressTimer) clearTimeout(this.saveProgressTimer);

    this.saveProgressTimer = setTimeout(() => {
      const toSave = this.pendingCfi;
      this.pendingCfi = null;
      if (toSave) {
        this.saveProgressToDb({ cfi: toSave });
      }
    }, 350);
  }

  updateStatus(location) {
    const displayed = location?.start?.displayed;
    const cfi = location?.start?.cfi;

    if (cfi) this.queueSaveCfi(cfi);

    const chapterText = displayed?.total
      ? `Chapter ${displayed.page}/${displayed.total}`
      : null;

    if (cfi && this.publisherPageList) {
      const publisherPage = this.publisherPageList.pageFromCfi(cfi);
      if (typeof publisherPage === "number" && publisherPage > 0) {
        const lastPublisherPage =
          this.publisherPageList.lastPage || publisherPage;
        this.pageStatusTarget.textContent = chapterText
          ? `Page ${publisherPage}/${lastPublisherPage} • ${chapterText}`
          : `Page ${publisherPage}/${lastPublisherPage}`;
        return;
      }
    }

    if (!cfi || !this.book?.locations || !this.totalBookPages) {
      this.pageStatusTarget.textContent = chapterText || "Reading";
      return;
    }

    const globalIndex = this.book.locations.locationFromCfi(cfi);
    if (typeof globalIndex !== "number" || globalIndex < 0) {
      this.pageStatusTarget.textContent = chapterText || "Reading";
      return;
    }

    const globalPage = globalIndex + 1;

    this.pageStatusTarget.textContent = chapterText
      ? `Page ${globalPage}/${this.totalBookPages} • ${chapterText}`
      : `Page ${globalPage}/${this.totalBookPages}`;
  }

  async generateBookLocations() {
    if (!this.book) return;

    await this.book.ready;

    if (this.book.loaded?.pageList) {
      await this.book.loaded.pageList;
      const pageList = this.book.pageList;
      if (
        pageList &&
        Array.isArray(pageList.pages) &&
        pageList.pages.length > 0 &&
        Array.isArray(pageList.locations) &&
        pageList.locations.length > 0
      ) {
        this.publisherPageList = pageList;
      }
    }

    await this.book.locations.generate(1024);
    this.totalBookPages = this.book.locations.length();

    const currentLocation = this.rendition?.currentLocation?.();
    if (currentLocation) {
      this.updateStatus(currentLocation);
    }
  }

  async initialize() {
    if (!window.ePub || !this.hasStageTarget || !this.epubUrlValue) {
      this.pageStatusTarget.textContent = "Reader failed to initialize";
      return;
    }

    const FAMILY_KEY = "reader.fontFamily";
    const SIZE_KEY = "reader.fontSize";

    const savedFamily = localStorage.getItem(FAMILY_KEY);
    const savedSize = localStorage.getItem(SIZE_KEY);
    if (savedFamily) this.fontFamilyTarget.value = savedFamily;
    if (savedSize) this.fontSizeTarget.value = savedSize;
    this.fontSizeOutputTarget.textContent = `${this.fontSizeTarget.value}px`;

    this.book = window.ePub(this.epubUrlValue, { openAs: "epub" });

    this.rendition = this.book.renderTo(this.stageTarget, {
      width: "100%",
      height: "100%",
      flow: "paginated",
      spread: "none",
    });

    this.applyTheme();

    this.rendition.on("relocated", (location) => {
      this.updateStatus(location);
    });

    const initialCfi = await this.loadProgressFromDb();
    try {
      await this.rendition.display(initialCfi || undefined);
      await this.generateBookLocations();
    } catch {
      this.pageStatusTarget.textContent = "Could not display this book";
    }

    window.addEventListener("keydown", this.keyDownHandler);
    window.addEventListener("resize", this.resizeHandler);
  }

  applyTheme() {
    if (!this.rendition) return;

    this.rendition.themes.default({
      body: {
        "font-family": this.fontFamilyTarget.value,
        "font-size": `${this.fontSizeTarget.value}px`,
        "line-height": "1.5",
        margin: "1.6rem auto",
        "max-width": "680px",
      },
      p: { "text-indent": "1.4em" },
      "p:first-child, h1 + p, h2 + p, h3 + p, h4 + p, h5 + p, h6 + p": {
        "text-indent": "0",
      },
      img: {
        display: "block",
        margin: "0.4rem auto 2em",
        "max-width": "100%",
        height: "auto",
      },
    });

    // Ensure dynamic control updates are applied immediately in the rendered spine.
    this.rendition.themes.override("font-family", this.fontFamilyTarget.value);
    this.rendition.themes.fontSize(`${this.fontSizeTarget.value}px`);
  }

  prev(event) {
    event.preventDefault();
    this.rendition?.prev();
  }

  next(event) {
    event.preventDefault();
    this.rendition?.next();
  }

  fontFamilyChanged() {
    localStorage.setItem("reader.fontFamily", this.fontFamilyTarget.value);
    if (this.rendition) {
      this.rendition.themes.override(
        "font-family",
        this.fontFamilyTarget.value,
      );
    }
    this.applyTheme();
  }

  fontSizeChanged() {
    this.fontSizeOutputTarget.textContent = `${this.fontSizeTarget.value}px`;
    localStorage.setItem("reader.fontSize", this.fontSizeTarget.value);
    if (this.rendition) {
      this.rendition.themes.fontSize(`${this.fontSizeTarget.value}px`);
    }
    this.applyTheme();
  }

  onKeydown(event) {
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      this.rendition?.prev();
    } else if (event.key === "ArrowRight") {
      event.preventDefault();
      this.rendition?.next();
    }
  }

  onResize() {
    clearTimeout(this.resizeTimer);
    this.resizeTimer = setTimeout(() => {
      this.rendition?.resize("100%", "100%");
    }, 150);
  }
}
