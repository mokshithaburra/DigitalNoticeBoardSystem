document.addEventListener("DOMContentLoaded", function () {

    // Simple frontend navigation (no backend yet)
    const loginForm = document.getElementById("loginForm");

    if (loginForm) {
        loginForm.addEventListener("submit", function (e) {
            e.preventDefault();

            const role = document.getElementById("role").value;

            if (role === "admin") {
                window.location.href = "../admin/admin-dashboard.html";
            } else if (role === "student") {
                window.location.href = "../student/student-dashboard.html";
            } else {
                alert("Please select a role");
            }
        });
    }

});
