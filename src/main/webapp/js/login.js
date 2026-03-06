document.addEventListener("DOMContentLoaded", function () {
    const loginForm = document.getElementById("loginForm");
    if (!loginForm) {
        return;
    }

    const query = new URLSearchParams(window.location.search);
    const error = query.get("error");
    if (error) {
        const header = document.querySelector(".login-header");
        if (header) {
            const message = document.createElement("p");
            message.style.color = "#dc2626";
            message.style.marginTop = "8px";
            message.style.fontWeight = "500";
            message.textContent = error;
            header.appendChild(message);
        }
    }

    loginForm.setAttribute("method", "post");
    loginForm.setAttribute("action", "../login");
});
