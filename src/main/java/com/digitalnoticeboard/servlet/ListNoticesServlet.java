package com.digitalnoticeboard.servlet;

import com.digitalnoticeboard.dao.NoticeDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ListNoticesServlet extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(session.getAttribute("role"));
        String requestUri = request.getRequestURI();

        if (requestUri.endsWith("/admin/notices") && !"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (requestUri.endsWith("/student/notices") && !"student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("admin".equals(role)) {
            request.setAttribute("activeNotices", noticeDAO.getActiveNoticesForAdmin());
            request.setAttribute("expiredNotices", noticeDAO.getExpiredNotices());
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
            return;
        }

        request.setAttribute("activeNotices", noticeDAO.getActiveNoticesForStudent());
        request.setAttribute("expiredNotices", noticeDAO.getExpiredNotices());
        request.getRequestDispatcher("/student-dashboard.jsp").forward(request, response);
    }
}
