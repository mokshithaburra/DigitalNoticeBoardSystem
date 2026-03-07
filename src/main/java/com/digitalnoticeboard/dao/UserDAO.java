package com.digitalnoticeboard.dao;

import com.digitalnoticeboard.config.DBConnection;
import com.digitalnoticeboard.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User authenticateUser(String username, String password, String role) {
        String schema = System.getenv("DB_SCHEMA");
        if (schema == null || schema.trim().isEmpty()) {
            schema = System.getProperty("DB_SCHEMA");
        }

        String tableName = "users";
        if (schema != null && !schema.trim().isEmpty()) {
            tableName = schema.trim() + ".users";
        }

        String sql = "SELECT user_id, username, password, role, email FROM " + tableName +
            " WHERE LOWER(TRIM(username)) = LOWER(TRIM(?)) AND password = ? AND LOWER(TRIM(role)) = LOWER(TRIM(?))";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, username);
            preparedStatement.setString(2, password);
            preparedStatement.setString(3, role);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    User user = new User();
                    user.setUserId(resultSet.getInt("user_id"));
                    user.setUsername(resultSet.getString("username"));
                    user.setPassword(resultSet.getString("password"));
                    user.setRole(resultSet.getString("role"));
                    user.setEmail(resultSet.getString("email"));
                    return user;
                }
            }
        } catch (SQLException exception) {
            throw new RuntimeException("Authentication query failed. Check DB_URL/DB_USER/DB_SCHEMA and users table access.", exception);
        }

        return null;
    }
}
