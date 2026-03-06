package com.digitalnoticeboard.servlet;

import com.digitalnoticeboard.dao.NoticeDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class DeleteNoticeServlet extends HttpServlet {
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idText = request.getParameter("id");
        try {
            int noticeId = Integer.parseInt(idText);
            noticeDAO.deleteNotice(noticeId);
        } catch (Exception ignored) {
        }

        response.sendRedirect(request.getContextPath() + "/admin/notices");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "admin".equals(session.getAttribute("role"));
    }
}
