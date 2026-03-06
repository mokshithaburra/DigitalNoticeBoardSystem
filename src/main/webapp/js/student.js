document.addEventListener("DOMContentLoaded", function () {
    const filterButtons = document.querySelectorAll(".filter-btn");
    const noticesGrid = document.getElementById("noticesGrid");
    const emptyState = document.getElementById("emptyState");
    const searchInput = document.getElementById("searchNotices");

    if (!noticesGrid) {
        return;
    }

    const basePath = getBasePath();
    const apiUrl = basePath + "/api/notices";

    let allNotices = [];
    let activeCategory = "all";
    let activeSearch = "";

    filterButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            filterButtons.forEach(function (item) {
                item.classList.remove("active");
            });
            button.classList.add("active");
            activeCategory = button.dataset.category || "all";
            applyFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener("input", function (event) {
            activeSearch = (event.target.value || "").trim().toLowerCase();
            applyFilters();
        });
    }

    function fetchNotices() {
        fetch(apiUrl)
            .then(function (response) {
                return response.json().then(function (payload) {
                    if (!response.ok) {
                        const err = new Error(payload.error || "Unable to fetch notices");
                        err.status = response.status;
                        throw err;
                    }
                    return payload;
                });
            })
            .then(function (payload) {
                allNotices = Array.isArray(payload.notices) ? payload.notices : [];
                applyFilters();
            })
            .catch(function (error) {
                if (error.status === 401) {
                    window.location.href = basePath + "/auth/login.html";
                    return;
                }
                noticesGrid.innerHTML = "";
                toggleEmptyState(0);
            });
    }

    function applyFilters() {
        const filtered = allNotices.filter(function (notice) {
            const category = (notice.category || "").toLowerCase();
            const matchesCategory = activeCategory === "all" || category === activeCategory;
            const searchableText = ((notice.title || "") + " " + (notice.description || "")).toLowerCase();
            const matchesSearch = searchableText.includes(activeSearch);
            return matchesCategory && matchesSearch;
        });

        renderNotices(filtered);
        toggleEmptyState(filtered.length);
    }

    function renderNotices(notices) {
        if (!notices.length) {
            noticesGrid.innerHTML = "";
            return;
        }

        notices.sort(function (left, right) {
            const leftTime = Number(left.createdAtEpoch || 0);
            const rightTime = Number(right.createdAtEpoch || 0);
            return rightTime - leftTime;
        });

        noticesGrid.innerHTML = notices.map(function (notice) {
            const categoryKey = (notice.category || "general").toLowerCase();
            const priorityMeta = getPriorityMeta(notice.priority);
            const created = notice.createdAtEpoch ? new Date(Number(notice.createdAtEpoch)).toLocaleString() : "-";
            const expiry = notice.expiryDate || "No Expiry";

            return '<div class="notice-card ' + priorityMeta.cardClass + '" data-category="' + categoryKey + '">' +
                '<div class="notice-card-header">' +
                '<span class="badge badge-' + categoryKey + '">' + escapeHtml(notice.category) + '</span>' +
                '<span class="badge ' + priorityMeta.badgeClass + '">' + priorityMeta.label + ' Priority</span>' +
                '</div>' +
                '<h3 class="notice-card-title">' + escapeHtml(notice.title) + '</h3>' +
                '<p class="notice-card-description">' + escapeHtml(notice.description) + '</p>' +
                '<div class="notice-card-footer">' +
                '<span class="notice-date">📅 Posted: ' + created + '</span>' +
                '<span class="notice-expiry">⏰ Expires: ' + expiry + '</span>' +
                '</div>' +
                '</div>';
        }).join("");
    }

    function toggleEmptyState(visibleCount) {
        if (!emptyState || !noticesGrid) {
            return;
        }

        if (visibleCount === 0) {
            noticesGrid.style.display = "none";
            emptyState.style.display = "flex";
        } else {
            noticesGrid.style.display = "grid";
            emptyState.style.display = "none";
        }
    }

    function getPriorityMeta(priority) {
        if (Number(priority) === 1) {
            return { label: "High", badgeClass: "badge-high", cardClass: "priority-high" };
        }

        if (Number(priority) === 3) {
            return { label: "Low", badgeClass: "badge-low", cardClass: "priority-low" };
        }

        return { label: "Medium", badgeClass: "badge-medium", cardClass: "priority-medium" };
    }

    function getBasePath() {
        const path = window.location.pathname;
        const marker = "/student/";
        const index = path.indexOf(marker);
        return index >= 0 ? path.substring(0, index) : "";
    }

    function escapeHtml(value) {
        if (!value) {
            return "";
        }

        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    fetchNotices();
    setInterval(fetchNotices, 10000);
});
