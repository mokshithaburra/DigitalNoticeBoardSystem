package com.digitalnoticeboard.servlet;

import com.digitalnoticeboard.dao.UserDAO;
import com.digitalnoticeboard.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String force = request.getParameter("force");
        if ("true".equalsIgnoreCase(force)) {
            HttpSession existingSession = request.getSession(false);
            if (existingSession != null) {
                existingSession.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/auth/login.html");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("role") != null) {
            String role = String.valueOf(session.getAttribute("role"));
            if ("admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/admin-dashboard.html");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/student/student-dashboard.html");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/auth/login.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        if (isBlank(username) || isBlank(password) || isBlank(role)) {
            response.sendRedirect(request.getContextPath() + "/auth/login.html?error=Username%2C%20password%2C%20and%20role%20are%20required");
            return;
        }

        User user = userDAO.authenticateUser(username.trim(), password.trim(), role.trim());
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.html?error=Invalid%20credentials");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("role", user.getRole());

        if ("admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/admin-dashboard.html");
        } else {
            response.sendRedirect(request.getContextPath() + "/student/student-dashboard.html");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
