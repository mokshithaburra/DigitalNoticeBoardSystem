document.addEventListener("DOMContentLoaded", function () {

    // Filter functionality
    const filterButtons = document.querySelectorAll(".filter-btn");
    const noticeCards = document.querySelectorAll(".notice-card");
    const emptyState = document.getElementById("emptyState");
    const noticesGrid = document.getElementById("noticesGrid");
    const searchInput = document.getElementById("searchNotices");

    // Filter button click handling
    filterButtons.forEach(btn => {
        btn.addEventListener("click", function () {

            // Update active button
            filterButtons.forEach(b => b.classList.remove("active"));
            this.classList.add("active");

            const category = this.dataset.category;
            filterNotices(category);
        });
    });

    function filterNotices(category) {
        let visibleCount = 0;

        noticeCards.forEach(card => {
            if (category === "all" || card.dataset.category === category) {
                card.style.display = "block";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });

        toggleEmptyState(visibleCount);
    }

    // Search functionality
    if (searchInput) {
        searchInput.addEventListener("input", function (e) {
            const searchTerm = e.target.value.toLowerCase();
            const activeBtn = document.querySelector(".filter-btn.active");
            const activeCategory = activeBtn ? activeBtn.dataset.category : "all";

            let visibleCount = 0;

            noticeCards.forEach(card => {
                const title = card.querySelector(".notice-card-title")?.textContent.toLowerCase() || "";
                const description = card.querySelector(".notice-card-description")?.textContent.toLowerCase() || "";
                const category = card.dataset.category;

                const matchesSearch = title.includes(searchTerm) || description.includes(searchTerm);
                const matchesCategory = activeCategory === "all" || category === activeCategory;

                if (matchesSearch && matchesCategory) {
                    card.style.display = "block";
                    visibleCount++;
                } else {
                    card.style.display = "none";
                }
            });

            toggleEmptyState(visibleCount);
        });
    }

    // Empty state toggle
    function toggleEmptyState(visibleCount) {
        if (!emptyState || !noticesGrid) return;

        if (visibleCount === 0) {
            noticesGrid.style.display = "none";
            emptyState.style.display = "flex";
        } else {
            noticesGrid.style.display = "grid";
            emptyState.style.display = "none";
        }
    }

});
