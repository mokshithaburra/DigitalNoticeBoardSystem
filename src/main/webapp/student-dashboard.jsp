<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.digitalnoticeboard.model.Notice" %>
<%
    if (session == null || session.getAttribute("role") == null || !"student".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Notice> expiredNotices = (List<Notice>) request.getAttribute("expiredNotices");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #f8fafc; color: #111827; }
        .container { max-width: 1100px; margin: 24px auto; padding: 0 16px; }
        .top { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
        .toolbar { display: flex; gap: 8px; flex-wrap: wrap; margin: 14px 0; }
        .btn { border: 1px solid #cbd5e1; background: #fff; padding: 8px 12px; border-radius: 999px; cursor: pointer; }
        .btn.active { background: #2563eb; color: #fff; border-color: #2563eb; }
        .search { width: 280px; max-width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; }
        .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px; }
        .card { background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-left: 5px solid #9ca3af; }
        .priority-1 { border-left-color: #dc2626; }
        .priority-2 { border-left-color: #d97706; }
        .priority-3 { border-left-color: #16a34a; }
        .meta { font-size: 12px; color: #6b7280; margin-bottom: 8px; }
        .empty { background: #fff; border-radius: 10px; padding: 16px; }
        .faded-section { margin-top: 26px; opacity: 0.65; }
        .switch-link { text-decoration: none; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; color: #1f2937; }
    </style>
</head>
<body>
<div class="container" id="dashboardRoot" data-api-url="<%= request.getContextPath() %>/api/notices">
    <div class="top">
        <h2>Student Dashboard</h2>
        <a class="switch-link" href="<%= request.getContextPath() %>/login?force=true">Switch User</a>
    </div>

    <div class="toolbar" id="categoryFilters">
        <button class="btn active" data-category="all">All</button>
        <button class="btn" data-category="Exam">Exam</button>
        <button class="btn" data-category="Events">Events</button>
        <button class="btn" data-category="Circulars">Circulars</button>
        <button class="btn" data-category="Placement">Placement</button>
        <button class="btn" data-category="General">General</button>
    </div>

    <input id="searchInput" class="search" type="text" placeholder="Search by title or description...">

    <div id="noticesContainer" class="cards" style="margin-top:14px;"></div>

    <div class="faded-section">
        <h3>Expired Notices</h3>
        <div class="cards">
            <% if (expiredNotices != null && !expiredNotices.isEmpty()) { %>
                <% for (Notice notice : expiredNotices) { %>
                <div class="card priority-<%= notice.getPriority() %>">
                    <h4><%= notice.getTitle() %></h4>
                    <div class="meta"><%= notice.getCategory() %> • Expired on <%= notice.getExpiryDate() %></div>
                    <p><%= notice.getDescription() %></p>
                </div>
                <% } %>
            <% } else { %>
                <div class="empty">No expired notices.</div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= request.getContextPath() %>/js/dashboard.js"></script>
</body>
</html>
