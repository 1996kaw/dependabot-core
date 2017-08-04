# frozen_string_literal: true
require "json"

module Dependabot
  module UpdateCheckers
    class Base
      attr_reader :dependency, :dependency_files, :github_access_token

      def initialize(dependency:, dependency_files:, github_access_token:)
        @dependency = dependency
        @dependency_files = dependency_files
        @github_access_token = github_access_token
      end

      def needs_update?
        # Look at the very latest version before considering resolvability. If
        # we're already up-to-date with it then we don't need to bother doing
        # resolution (which is generally slow).
        return false if latest_version && latest_version <= dependency.version

        return false if latest_resolvable_version.nil?

        latest_resolvable_version > dependency.version
      end

      def updated_dependency
        Dependency.new(
          name: dependency.name,
          version: latest_resolvable_version,
          previous_version: dependency.version,
          package_manager: dependency.package_manager
        )
      end

      def latest_version
        raise NotImplementedError
      end

      def latest_resolvable_version
        raise NotImplementedError
      end
    end
  end
end
