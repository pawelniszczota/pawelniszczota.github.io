(() => {
  const button = document.querySelector(".menu-button");
  const navigation = document.querySelector("#main-navigation");
  const printButton = document.querySelector("[data-print]");

  if (printButton) {
    printButton.addEventListener("click", () => window.print());
  }

  if (!button || !navigation) return;

  const closeNavigation = (restoreFocus = false) => {
    const wasOpen = document.body.classList.contains("nav-open");
    document.body.classList.remove("nav-open");
    button.setAttribute("aria-expanded", "false");
    button.setAttribute("aria-label", "Open navigation");
    if (wasOpen && restoreFocus) button.focus();
  };

  button.addEventListener("click", () => {
    const open = !document.body.classList.contains("nav-open");
    if (!open) {
      closeNavigation(true);
      return;
    }

    document.body.classList.add("nav-open");
    button.setAttribute("aria-expanded", "true");
    button.setAttribute("aria-label", "Close navigation");
    navigation.querySelector("a")?.focus();
  });

  navigation.addEventListener("click", (event) => {
    if (event.target.closest("a")) closeNavigation();
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeNavigation(true);
  });

  window.addEventListener("resize", () => {
    if (window.innerWidth > 820) closeNavigation();
  });
})();
