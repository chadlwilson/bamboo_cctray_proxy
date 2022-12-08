require 'sinatra'
require 'singleton'
require 'concurrent'
require './app/bamboo_to_cctray'

CACHE_EXPIRY_SECONDS = 30

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 7001

before do
  cache_control :public, :must_revalidate, :max_age => CACHE_EXPIRY_SECONDS
end

get '/dashboard/cctray.xml' do
  logger.info "Processing request from #{request.ip}/#{request.user_agent}"
  content_type 'application/xml; charset=UTF-8'
  body BambooToCcTrayRunner.instance.to_cctray
end

class BambooToCcTrayRunner
  include Singleton

  def initialize
    @bamboo_to_cctray = BambooToCcTray.new
    @cache_update_lock = Concurrent::ReadWriteLock.new
  end

  def to_cctray
    cache_for(CACHE_EXPIRY_SECONDS) do
      @bamboo_to_cctray.to_cctray
    end
  end

  private
  def cache_for(secs)
    return cached_result if cache_valid?(secs)
    @cache_update_lock.with_write_lock do
      return cached_result if cache_valid?(secs)
      result = yield
      update_cache(result)
    end
  end

  def cached_result
    Marshal.load(IO.read(cache_file_path))
  end

  def cache_valid?(secs)
    return false unless File.exist?(cache_file_path)

    time_since_cache_updated = Time.now - File.mtime(cache_file_path)
    puts "Time since cache updated: #{time_since_cache_updated} secs"

    time_since_cache_updated <= secs
  end

  def update_cache(result)
    File.open(cache_file_path, "w") do |cache_file|
      cache_file << Marshal.dump(result)
    end
    puts "Updated #{cache_file_path}"
    result
  end

  def cache_file_path
    cache_file_dir = File.join(File.dirname(__FILE__), '../../tmp/')
    FileUtils.mkdir_p(cache_file_dir)
    File.join(cache_file_dir, 'response.cache')
  end
end