document.addEventListener("DOMContentLoaded", function () {

    // Set minimum date to today for expiry date picker
    const expiryInput = document.getElementById("noticeExpiry");
    if (expiryInput) {
        expiryInput.min = new Date().toISOString().split("T")[0];
    }

    // Handle form submission (no backend yet)
    const noticeForm = document.getElementById("noticeForm");
    if (noticeForm) {
        noticeForm.addEventListener("submit", function (e) {
            e.preventDefault();
            alert("Notice created successfully! (Backend not implemented yet)");
            this.reset();
        });
    }

    // Handle edit buttons
    document.querySelectorAll(".btn-edit").forEach(btn => {
        btn.addEventListener("click", function () {
            alert("Edit functionality will be implemented with backend");
        });
    });

    // Handle delete buttons
    document.querySelectorAll(".btn-delete").forEach(btn => {
        btn.addEventListener("click", function () {
            if (confirm("Are you sure you want to delete this notice?")) {
                alert("Notice deleted! (Backend not implemented yet)");
            }
        });
    });

    // Handle search
    const searchInput = document.getElementById("searchNotices");
    if (searchInput) {
        searchInput.addEventListener("input", function (e) {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll("#noticesTableBody tr");

            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? "" : "none";
            });
        });
    }

});
