package com.digitalnoticeboard.dao;

import com.digitalnoticeboard.config.DBConnection;
import com.digitalnoticeboard.model.Notice;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NoticeDAO {

    public boolean createNotice(Notice notice) {
        String sql = "INSERT INTO notices (title, description, category, priority, expiry_date, created_by) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, notice.getTitle());
            preparedStatement.setString(2, notice.getDescription());
            preparedStatement.setString(3, notice.getCategory());
            preparedStatement.setInt(4, notice.getPriority());

            if (notice.getExpiryDate() != null) {
                preparedStatement.setDate(5, notice.getExpiryDate());
            } else {
                preparedStatement.setNull(5, java.sql.Types.DATE);
            }

            preparedStatement.setInt(6, notice.getCreatedBy());
            return preparedStatement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }

    public boolean updateNotice(Notice notice) {
        String sql = "UPDATE notices SET title = ?, description = ?, category = ?, priority = ?, expiry_date = ? WHERE notice_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, notice.getTitle());
            preparedStatement.setString(2, notice.getDescription());
            preparedStatement.setString(3, notice.getCategory());
            preparedStatement.setInt(4, notice.getPriority());

            if (notice.getExpiryDate() != null) {
                preparedStatement.setDate(5, notice.getExpiryDate());
            } else {
                preparedStatement.setNull(5, java.sql.Types.DATE);
            }

            preparedStatement.setInt(6, notice.getNoticeId());
            return preparedStatement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }

    public boolean deleteNotice(int noticeId) {
        String sql = "DELETE FROM notices WHERE notice_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setInt(1, noticeId);
            return preparedStatement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }

    public Notice getNoticeById(int noticeId) {
        String sql = "SELECT notice_id, title, description, category, priority, created_at, expiry_date, created_by FROM notices WHERE notice_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setInt(1, noticeId);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    return mapNotice(resultSet);
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return null;
    }

    public List<Notice> getActiveNoticesForAdmin() {
        String sql = "SELECT notice_id, title, description, category, priority, created_at, expiry_date, created_by " +
                "FROM notices WHERE expiry_date IS NULL OR expiry_date >= CURRENT_DATE " +
                "ORDER BY created_at DESC";
        return getNotices(sql);
    }

    public List<Notice> getActiveNoticesForStudent() {
        String sql = "SELECT notice_id, title, description, category, priority, created_at, expiry_date, created_by " +
                "FROM notices WHERE expiry_date IS NULL OR expiry_date >= CURRENT_DATE " +
                "ORDER BY priority ASC, created_at DESC";
        return getNotices(sql);
    }

    public List<Notice> getExpiredNotices() {
        String sql = "SELECT notice_id, title, description, category, priority, created_at, expiry_date, created_by " +
                "FROM notices WHERE expiry_date < CURRENT_DATE ORDER BY created_at DESC";
        return getNotices(sql);
    }

    private List<Notice> getNotices(String sql) {
        List<Notice> notices = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                notices.add(mapNotice(resultSet));
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return notices;
    }

    private Notice mapNotice(ResultSet resultSet) throws SQLException {
        Notice notice = new Notice();
        notice.setNoticeId(resultSet.getInt("notice_id"));
        notice.setTitle(resultSet.getString("title"));
        notice.setDescription(resultSet.getString("description"));
        notice.setCategory(resultSet.getString("category"));
        notice.setPriority(resultSet.getInt("priority"));
        notice.setCreatedAt(resultSet.getTimestamp("created_at"));

        Date expiryDate = resultSet.getDate("expiry_date");
        notice.setExpiryDate(expiryDate);

        notice.setCreatedBy(resultSet.getInt("created_by"));
        return notice;
    }
}
