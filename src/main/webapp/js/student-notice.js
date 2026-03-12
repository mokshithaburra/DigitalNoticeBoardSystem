document.addEventListener("DOMContentLoaded", function () {
    const card = document.getElementById("noticeDetailsCard");
    if (!card) {
        return;
    }

    const basePath = getBasePath();
    const noticeId = getNoticeId();

    if (!noticeId) {
        card.innerHTML = '<p class="attachment-empty">Invalid notice link. Please return to dashboard.</p>';
        return;
    }

    fetch(basePath + "/api/notices?noticeId=" + encodeURIComponent(noticeId))
        .then(function (response) {
            return response.json().then(function (payload) {
                if (!response.ok) {
                    const err = new Error(payload.error || "Unable to load notice");
                    err.status = response.status;
                    throw err;
                }
                return payload;
            });
        })
        .then(function (payload) {
            renderNotice(payload.notice || null);
        })
        .catch(function (error) {
            if (error.status === 401) {
                window.location.href = basePath + "/auth/login.html";
                return;
            }
            card.innerHTML = '<p class="attachment-empty">' + escapeHtml(error.message || "Unable to load notice") + '</p>';
        });

    function renderNotice(notice) {
        if (!notice) {
            card.innerHTML = '<p class="attachment-empty">Notice not found.</p>';
            return;
        }

        const created = notice.createdAtEpoch ? new Date(Number(notice.createdAtEpoch)).toLocaleString() : "-";
        const expiry = notice.expiryDate || "No Expiry";
        const attachment = buildAttachmentBlock(notice);

        card.innerHTML = '' +
            '<div class="notice-card-header">' +
            '<span class="badge badge-' + escapeHtml((notice.category || "general").toLowerCase()) + '">' + escapeHtml(notice.category || "General") + '</span>' +
            '<span class="badge badge-medium">Priority ' + escapeHtml(String(notice.priority || "2")) + '</span>' +
            '</div>' +
            '<h2 class="notice-card-title">' + escapeHtml(notice.title || "Untitled Notice") + '</h2>' +
            '<p class="notice-card-description">' + escapeHtml(notice.description || "") + '</p>' +
            '<div class="notice-card-footer">' +
            '<span class="notice-date">Posted: ' + created + '</span>' +
            '<span class="notice-expiry">Expires: ' + expiry + '</span>' +
            '</div>' +
            attachment;
    }

    function buildAttachmentBlock(notice) {
        const url = notice.attachmentUrl || "";
        if (!url) {
            return '<div class="attachment-row attachment-empty">Attachment: Not provided</div>';
        }
        return '<div class="attachment-row"><span class="attachment-label">Attachment:</span><a class="attachment-btn" href="' + escapeHtml(url) + '" target="_blank" rel="noopener">Download Attachment</a></div>';
    }

    function getNoticeId() {
        const params = new URLSearchParams(window.location.search);
        return params.get("noticeId");
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
});
