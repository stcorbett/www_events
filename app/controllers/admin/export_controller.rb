module Admin
  class ExportController < ApplicationController
    before_action :require_admin

    # Tables listed in foreign-key-safe insertion order. Only application
    # tables — schema_migrations, ar_internal_metadata, and any Heroku/
    # Postgres-internal tables are intentionally excluded.
    TABLE_MODELS = {
      "users"         => User,
      "neighborhoods" => Neighborhood,
      "locations"     => Location,
      "camps"         => Camp,
      "departments"   => Department,
      "events"        => Event,
      "event_times"   => EventTime,
      "hosted_files"  => HostedFile,
    }.freeze

    def index
    end

    def download
      filename = "www_events_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.sql"
      send_data build_sql_dump, type: "application/sql", filename: filename, disposition: "attachment"
    end

    private

    def build_sql_dump
      lines = []
      lines << "-- WhatWhereWhen events SQL dump"
      lines << "-- Generated at #{Time.zone.now.iso8601}"
      lines << "-- Run with: psql YOUR_DATABASE < this_file.sql"
      lines << ""
      lines << "BEGIN;"
      lines << ""

      truncate_tables = TABLE_MODELS.keys.reverse.map { |t| connection.quote_table_name(t) }.join(", ")
      lines << "TRUNCATE TABLE #{truncate_tables} RESTART IDENTITY CASCADE;"
      lines << ""

      TABLE_MODELS.each do |table_name, model|
        lines.concat(dump_table_lines(table_name, model))
      end

      TABLE_MODELS.each_key do |table_name|
        lines << reset_sequence_sql(table_name)
      end

      lines << ""
      lines << "COMMIT;"
      lines << ""
      lines.join("\n")
    end

    def dump_table_lines(table_name, _model)
      quoted_table = connection.quote_table_name(table_name)
      result = connection.exec_query("SELECT * FROM #{quoted_table} ORDER BY id")

      out = ["-- #{table_name}"]
      if result.rows.empty?
        out << "-- (no rows)"
      else
        column_list = result.columns.map { |c| connection.quote_column_name(c) }.join(", ")
        result.rows.each do |row|
          values = row.map { |v| connection.quote(v) }.join(", ")
          out << "INSERT INTO #{quoted_table} (#{column_list}) VALUES (#{values});"
        end
      end
      out << ""
      out
    end

    def reset_sequence_sql(table_name)
      quoted_table = connection.quote_table_name(table_name)
      "SELECT setval(pg_get_serial_sequence(#{connection.quote(table_name)}, 'id'), " \
        "COALESCE((SELECT MAX(id) FROM #{quoted_table}), 1), " \
        "(SELECT COUNT(*) FROM #{quoted_table}) > 0);"
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end
