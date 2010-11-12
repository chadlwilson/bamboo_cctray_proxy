require 'singleton'
require 'ramaze'
require 'app/bamboo_to_cctray'

class Dashboard < Ramaze::Controller
  CACHE_EXPIRY_SECONDS = 300

  map '/dashboard'

  define_method 'cctray.xml' do
    Ramaze::Log.debug Ramaze::Current.request.inspect
    
    response = Ramaze::Current.response
    response.header['Content-Type'] = 'application/xml; charset=UTF-8'
    response.header['Cache-Control'] = "max-age=#{CACHE_EXPIRY_SECONDS}, s-maxage=#{CACHE_EXPIRY_SECONDS}"
    
    BambooToCcTrayRunner.instance.to_cctray
  end
    
  class BambooToCcTrayRunner
    include Singleton
    
    def initialize
      @bamboo_to_cctray = BambooToCcTray.new
    end
    
    def to_cctray
      cache_for(CACHE_EXPIRY_SECONDS) do
        @bamboo_to_cctray.to_cctray
      end
    end
    
    private
    def cache_for(secs)
      return cached_result if cache_valid?(secs)
      result = yield
      update_cache(result)
    end

    def cached_result
      Marshal.load(IO.read(cache_file_path))
    end

    def cache_valid?(secs)
      return false unless File.exist?(cache_file_path)

      time_since_cache_updated = Time.now - File.mtime(cache_file_path)
      Ramaze::Log.debug "Time since cache updated: #{time_since_cache_updated} secs"

      time_since_cache_updated <= secs
    end

    def update_cache(result)
      File.open(cache_file_path, "w") do |cache_file|
        cache_file << Marshal.dump(result)
      end
      Ramaze::Log.debug "Updated #{cache_file_path}"
      result    
    end

    def cache_file_path
      cache_file_dir = File.join(File.dirname(__FILE__), '../../tmp/')
      FileUtils.mkdir_p(cache_file_dir)
      File.join(cache_file_dir, 'response.cache')
    end
  end
end