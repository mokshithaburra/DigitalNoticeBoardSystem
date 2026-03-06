document.addEventListener("DOMContentLoaded", function () {
    const form = document.getElementById("noticeForm");
    const tableBody = document.getElementById("noticesTableBody");
    const searchInput = document.getElementById("searchNotices");
    const expiryInput = document.getElementById("noticeExpiry");

    if (!form || !tableBody) {
        return;
    }

    if (expiryInput) {
        expiryInput.min = new Date().toISOString().split("T")[0];
    }

    const basePath = getBasePath();
    const apiUrl = basePath + "/api/admin/notices";

    loadNotices();

    form.addEventListener("submit", function (event) {
        event.preventDefault();

        const payload = new URLSearchParams();
        payload.set("action", "create");
        payload.set("title", document.getElementById("noticeTitle").value);
        payload.set("description", document.getElementById("noticeDescription").value);
        payload.set("category", document.getElementById("noticeCategory").value);
        payload.set("priority", document.getElementById("noticePriority").value);
        payload.set("expiryDate", document.getElementById("noticeExpiry").value);

        fetch(apiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: payload.toString()
        })
            .then(handleApiResponse)
            .then(function () {
                alert("Notice created successfully");
                form.reset();
                if (expiryInput) {
                    expiryInput.min = new Date().toISOString().split("T")[0];
                }
                loadNotices();
            })
            .catch(function (error) {
                alert(error.message || "Failed to create notice");
            });
    });

    tableBody.addEventListener("click", function (event) {
        const editButton = event.target.closest(".btn-edit");
        const deleteButton = event.target.closest(".btn-delete");

        if (editButton) {
            const noticeId = editButton.dataset.id;
            editNotice(noticeId);
            return;
        }

        if (deleteButton) {
            const noticeId = deleteButton.dataset.id;
            deleteNotice(noticeId);
        }
    });

    if (searchInput) {
        searchInput.addEventListener("input", function (event) {
            const searchTerm = (event.target.value || "").toLowerCase();
            const rows = tableBody.querySelectorAll("tr");

            rows.forEach(function (row) {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? "" : "none";
            });
        });
    }

    function loadNotices() {
        fetch(apiUrl)
            .then(handleApiResponse)
            .then(function (payload) {
                const notices = Array.isArray(payload.activeNotices) ? payload.activeNotices : [];
                renderRows(notices);
            })
            .catch(function (error) {
                if (error.status === 401) {
                    window.location.href = basePath + "/auth/login.html";
                    return;
                }
                tableBody.innerHTML = '<tr><td colspan="7">Unable to load notices.</td></tr>';
            });
    }

    function renderRows(notices) {
        if (!notices.length) {
            tableBody.innerHTML = '<tr><td colspan="7">No notices available.</td></tr>';
            return;
        }

        tableBody.innerHTML = notices.map(function (notice) {
            const categoryKey = (notice.category || "general").toLowerCase();
            const priorityMeta = getPriorityMeta(notice.priority);
            const createdAt = notice.createdAtEpoch ? new Date(Number(notice.createdAtEpoch)).toLocaleString() : "-";
            const expiryDate = notice.expiryDate || "-";
            const isActive = !notice.expiryDate || new Date(notice.expiryDate) >= startOfToday();

            return '<tr>' +
                '<td><div class="notice-title-cell"><strong>' + escapeHtml(notice.title) + '</strong><p class="notice-desc">' + escapeHtml(notice.description) + '</p></div></td>' +
                '<td><span class="badge badge-' + categoryKey + '">' + escapeHtml(notice.category) + '</span></td>' +
                '<td><span class="badge ' + priorityMeta.badgeClass + '">' + priorityMeta.label + '</span></td>' +
                '<td>' + createdAt + '</td>' +
                '<td>' + expiryDate + '</td>' +
                '<td><span class="' + (isActive ? 'status-active' : 'status-expired') + '">' + (isActive ? 'Active' : 'Expired') + '</span></td>' +
                '<td><div class="action-buttons">' +
                '<button class="btn-icon btn-edit" data-id="' + notice.noticeId + '" title="Edit">✏️</button>' +
                '<button class="btn-icon btn-delete" data-id="' + notice.noticeId + '" title="Delete">🗑️</button>' +
                '</div></td>' +
                '</tr>';
        }).join("");
    }

    function editNotice(noticeId) {
        const row = tableBody.querySelector('button.btn-edit[data-id="' + noticeId + '"]')?.closest("tr");
        if (!row) {
            return;
        }

        const title = prompt("Edit title", row.querySelector("strong")?.textContent || "");
        if (title === null) return;

        const description = prompt("Edit description", row.querySelector(".notice-desc")?.textContent || "");
        if (description === null) return;

        const category = prompt("Edit category (exam/event/emergency/general/academic/placement)", row.querySelector("td:nth-child(2) .badge")?.textContent?.toLowerCase() || "general");
        if (category === null) return;

        const priority = prompt("Edit priority (high/medium/low)", row.querySelector("td:nth-child(3) .badge")?.textContent?.toLowerCase().includes("high") ? "high" : row.querySelector("td:nth-child(3) .badge")?.textContent?.toLowerCase().includes("low") ? "low" : "medium");
        if (priority === null) return;

        const expiryDate = prompt("Edit expiry date (YYYY-MM-DD)", row.querySelector("td:nth-child(5)")?.textContent || "");
        if (expiryDate === null) return;

        const payload = new URLSearchParams();
        payload.set("action", "update");
        payload.set("noticeId", noticeId);
        payload.set("title", title);
        payload.set("description", description);
        payload.set("category", category);
        payload.set("priority", priority);
        payload.set("expiryDate", expiryDate);

        fetch(apiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: payload.toString()
        })
            .then(handleApiResponse)
            .then(function () {
                alert("Notice updated successfully");
                loadNotices();
            })
            .catch(function (error) {
                alert(error.message || "Failed to update notice");
            });
    }

    function deleteNotice(noticeId) {
        if (!confirm("Are you sure you want to delete this notice?")) {
            return;
        }

        const payload = new URLSearchParams();
        payload.set("action", "delete");
        payload.set("noticeId", noticeId);

        fetch(apiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: payload.toString()
        })
            .then(handleApiResponse)
            .then(function () {
                loadNotices();
            })
            .catch(function (error) {
                alert(error.message || "Failed to delete notice");
            });
    }

    function handleApiResponse(response) {
        return response.json().then(function (payload) {
            if (!response.ok) {
                const err = new Error(payload.error || "Request failed");
                err.status = response.status;
                throw err;
            }
            return payload;
        });
    }

    function getPriorityMeta(priority) {
        if (Number(priority) === 1) {
            return { label: "High", badgeClass: "badge-high" };
        }

        if (Number(priority) === 3) {
            return { label: "Low", badgeClass: "badge-low" };
        }

        return { label: "Medium", badgeClass: "badge-medium" };
    }

    function getBasePath() {
        const path = window.location.pathname;
        const marker = "/admin/";
        const index = path.indexOf(marker);
        return index >= 0 ? path.substring(0, index) : "";
    }

    function startOfToday() {
        const date = new Date();
        date.setHours(0, 0, 0, 0);
        return date;
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
});
