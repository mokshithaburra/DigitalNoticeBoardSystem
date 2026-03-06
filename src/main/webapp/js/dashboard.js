(function () {
    const root = document.getElementById('dashboardRoot');
    if (!root) {
        return;
    }

    const apiUrl = root.dataset.apiUrl;
    const noticesContainer = document.getElementById('noticesContainer');
    const searchInput = document.getElementById('searchInput');
    const categoryFilters = document.getElementById('categoryFilters');

    let allNotices = [];
    let activeCategory = 'all';
    let activeSearch = '';

    function escapeHtml(value) {
        if (!value) {
            return '';
        }

        return value
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function applyFilters() {
        const filtered = allNotices.filter(function (notice) {
            const categoryMatches = activeCategory === 'all' || (notice.category || '').toLowerCase() === activeCategory.toLowerCase();
            const searchableText = ((notice.title || '') + ' ' + (notice.description || '')).toLowerCase();
            const searchMatches = searchableText.indexOf(activeSearch) !== -1;
            return categoryMatches && searchMatches;
        });

        filtered.sort(function (left, right) {
            const leftTime = new Date(left.createdAt).getTime() || 0;
            const rightTime = new Date(right.createdAt).getTime() || 0;
            return rightTime - leftTime;
        });

        renderNotices(filtered);
    }

    function renderNotices(notices) {
        if (!notices.length) {
            noticesContainer.innerHTML = '<div class="empty">No notices found for selected filters.</div>';
            return;
        }

        noticesContainer.innerHTML = notices.map(function (notice) {
            const createdAt = notice.createdAt ? new Date(notice.createdAt).toLocaleString() : 'N/A';
            const expiryDate = notice.expiryDate ? notice.expiryDate : 'No Expiry';
            const delay = typeof notice.publishToDisplaySeconds === 'number' ? notice.publishToDisplaySeconds : 0;

            return '<div class="card priority-' + notice.priority + '">' +
                '<h4>' + escapeHtml(notice.title) + '</h4>' +
                '<div class="meta">' + escapeHtml(notice.category) + ' • Priority ' + notice.priority + '</div>' +
                '<p>' + escapeHtml(notice.description) + '</p>' +
                '<div class="meta">Posted: ' + createdAt + ' | Expires: ' + expiryDate + '</div>' +
                '<div class="meta">Publish-to-display: ' + delay + ' sec</div>' +
                '</div>';
        }).join('');
    }

    function fetchNotices() {
        fetch(apiUrl, { headers: { 'Accept': 'application/json' } })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Unable to fetch notices');
                }
                return response.json();
            })
            .then(function (payload) {
                allNotices = Array.isArray(payload.notices) ? payload.notices : [];
                applyFilters();
            })
            .catch(function () {
                noticesContainer.innerHTML = '<div class="empty">Unable to load notices right now.</div>';
            });
    }

    categoryFilters.addEventListener('click', function (event) {
        const button = event.target.closest('button[data-category]');
        if (!button) {
            return;
        }

        activeCategory = button.dataset.category || 'all';
        const buttons = categoryFilters.querySelectorAll('button[data-category]');
        buttons.forEach(function (item) {
            item.classList.toggle('active', item === button);
        });

        applyFilters();
    });

    searchInput.addEventListener('input', function (event) {
        activeSearch = (event.target.value || '').toLowerCase().trim();
        applyFilters();
    });

    fetchNotices();
    setInterval(fetchNotices, 10000);
})();
