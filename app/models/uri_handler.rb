require 'open-uri'

class UriHandler


  def self.getMatches(url)
    
    re = Match.all
    
    mat = []
    
    re.each do |r|     
      m =  r.match(url)
      next unless m
      mat << [url,r,m] if m
      if r.tag == "redirect"
        re.each do |s|
          ms = s.match(m[1])
          mat << [m[1],s, ms] if ms
        end
      else
 
      end
    end
    
    mat
  end

  def self.getFiles(path, filter)
    links = []
    if filter == nil
      filter  = "."
    end
    Dir.glob(path+"/**/*") {|f| 
      if !File.directory?(f) and f[%r{#{filter}}] 
        links << f 
      end
      }
    links
  end

  def self.getLowestDirs(path, filter)
    links = []
    Dir.glob(path+"/**/*") {|f| links << f if File.directory?(f)}
    
    #unfertig
    
    links
  end

# Load Page into Noktogiri
def self.loadNokogirPage (urlbase)

# uri = URI.parse(euri)
  begin
    oURL = open(urlbase)
    source = open(urlbase).read
#   response = Net::HTTP.get_response(uri)
    page = Nokogiri::HTML(source)
  rescue StandardError
  end
end

#Get the Urls of specified tag 

def self.getUrlsOfTag(urlbase, page, tag, attrName)
  
    links = page.css(tag)
    links = links.map {       |l| 
      begin
      URI.decode(URI.join(urlbase, (l.attr(attrName)||"").to_s).to_s)
      rescue
        "failure"
      end
      }
    return links
end

# Filter 
def self.filterUrls(urls, filter)
     
     if filter   
        urls.select! { |l| l[%r{#{filter}}] } 
     else 
       urls
     end
end

# extract content from @url with given match


def self.extract(match, url)
    
    sourcee = loadURL(url)
    page = Nokogiri::HTML(sourcee)

    urlbase = url
    
    links = page.css("a")
    links = links.map { |l| 
      begin
      URI.decode(URI.join(urlbase, (l.attr("href")||"").to_s).to_s)
      rescue
        "failure"
      end
      }
#    images = page.css("img")
#    images = images.map {|i| URI.join(urlbase, i.attr("src").to_s).to_s}
#    links += images
    
    links.select! { |l| l[%r{#{match.filter}}] } if match.filter
    if match.filter and match.filter.length >0 
       links.map! { |l| 
         
         match.result.gsub(/\$1/, %r{#{match.filter}}.match(l)[1])

         
        } 
     end

 
   links
 
end

def self.loadURL(u)
  
    Rails.cache.fetch(u, expires_in: 12.hours) do
          open(u).read
    end
 end

# Get Links V1.0

  def self.getLinks(euri, filter)

# uri = URI.parse(euri)
  urlbase = euri

  begin
#   response = Net::HTTP.get_response(uri)
#  page = Nokogiri::HTML(open(urlbase))    
    
 #   sourcee = response.body
 #   sourcee = open(euri).read
    sourcee = loadURL(euri)

    page = Nokogiri::HTML(sourcee)

#    @title = page.css("title")[0].text
    links = page.css("a")
    links = links.map {       |l| 
      begin
      URI.decode(URI.join(urlbase, (l.attr("href")||"").to_s).to_s)
      rescue
        "failure"
      end
      }
    images = page.css("img")
    images = images.map {|i| URI.join(urlbase, i.attr("src").to_s).to_s}
    links += images
    
   links.select! { |l| l[%r{#{filter}}] } if filter

#   links = links.map {|l| [l, URI(l).path, l[%r{#{filter}}] ]}

  rescue StandardError

  end
  
   links
end

def self.match(links,setlocation=nil)
   
   matchList = Array.new
   
   locuri = setlocation.uri if setlocation
   
   collectedLocations = []
   
   allLocations = Location.where(typ: URL_STORAGE_WEB) + Location.where(typ: URL_STORAGE_FS)
      
   links.each do |link| 
     locuri, path = nil
          
     if setlocation
       if link.first(locuri.length) == locuri
         loc = setlocation
       end
     else
       http = %r/httup:\/\//
       if link =~ http
         link = link.last(link.length-7)
         ls = ["http://"]+link.split(/\//)
       else
         ls = link.split(/\//)
       end

       
       blink = ""
       if collectedLocations
         ls.each do |l| 
           blink = blink + l 
         
#          if c = collectedLocations.detect {|l| l==blink}
#             locuri = c
#           end
           if c = allLocations.detect {|l| l.uri==blink}
             locuri = c
           end 
           blink = blink + "\/" 
         end
       end
       
#       unless locuri
#         blink = ""
#         ls.each do |l| 
#           blink = blink + l +  "\/" 
#
#           location = Location.where(uri: blink).first  
#           if location && location.storage_id
#             locuri = blink
#           end
#         end
#         if locuri
#             collectedLocations << locuri
#         end      
#      end
       
       if locuri
         length = link.length
         ulength = locuri.uri.length
         path = link.last(length-ulength)
       end
     
       matchList << ([link,locuri,path]+ canonize(path))
     end
   end
   
   matchList
end

def self.canonize(cpath)
  
     cpath = "" unless cpath
     split = cpath.split(/\//).reverse
     name = split[0] || ""    
     lfolder = (split[1] || "") +"/" # pfr 20170920 -  needs end with /
     
     split.reverse!
     
     path = ""
     le = split.length - 3
     if le > -1
       (0..le).each do |i|
         path += split[i] + "/"
       end
    end
    [path,lfolder,name]

end


def self.save(matchedLinks, mtype)
  
  
  matchedLinks.each do |a|
    
    next unless a[1]
    
    foldernew = false
    location = a[1]
    folder = Folder.where(storage_id: location.storage_id, mpath: a[3], lfolder: a[4]).first
    
    unless folder
      folder = Folder.new
      folder.storage_id = location.storage_id
      folder.mpath = a[3]
      folder.lfolder = a[4]
      folder.save
      
      foldernew = true
  
    end
   
    if foldernew or !Mfile.where(folder_id: folder.id, filename: a[5]).first
      mfile = Mfile.new
      mfile.filename = a[5]
      mfile.folder_id = folder.id
      mfile.mtype = mtype   
      
      mfile.save  
     
    end       
 end 
 Folder.resetFOLDERPATH
 end
 
 #*****
 def  matchURL(url, requrl)
   
   
   
 end
  
#****
 
 
 def self.mkDirectories(toLocation)

   storage = toLocation.storage
   uri = toLocation.uri
   
# check types   
   return "wrong typ in toLocation"    unless toLocation.typ == URL_STORAGE_FS  or toLocation.typ == URL_STORAGE_FSTN
   
# get all folder from storage

   folders = storage.folders
   
   folders.each do |folder|
     f = uri + "/"+ folder.mpath + "/" + folder.lfolder
     
     fsplit = f.split(/\//)
     fr = ""
     fsplit.each do |fs|
       next if fs == ""
       fr = File.join(fr,fs)
       puts "'"+f+"'"
       puts "dir='"+fr+"'"
       unless File.exist?(fr) 
          Dir.mkdir(fr)
       end
     end
   end
 
 end
 
 def self.copyFiles(fromLocation, toLocation, force = false) # force implementierung fehlt noch für File Copy
   
   storage = toLocation.storage
   return "different storages" unless fromLocation.storage == storage
   toUri = toLocation.uri
   fromUri = fromLocation.uri
# check types
#  return "wrong typ in fromLocation"  unless fromLocation.typ == URL_STORAGE_FS  or fromLocation.typ == URL_STORAGE_FSTN
   return "wrong typ in toLocation"    unless toLocation.typ == URL_STORAGE_FS  or toLocation.typ == URL_STORAGE_FSTN
   # todo: check FS or FSTN in common?
   
# get all folder from storage - fromLocation

   folders = storage.folders
   n = 0
   
   folders.each do |folder|
     from = File.join(fromUri, folder.mpath, folder.lfolder).gsub("//", "/").gsub(":/","://")
     to =   File.join(toUri, folder.mpath, folder.lfolder)
     
     mfiles = folder.mfiles
     
     mfiles.each do |mfile|           
        fromFile = File.join(from,mfile.filename)
        toFile   = File.join(to,mfile.filename)
        
 #       next if File.exist?(toFile) and not force # 20160108 
        
        if fromLocation.typ == URL_STORAGE_WEB           
              uri = URI.parse(URI.encode(fromFile))
              Net::HTTP.start(uri.host, uri.port) do |http|
                 response = http.get(uri.path)
                 open(toFile, "wb") do |file|
                     file.write(response.body)
                     n = n +1
                 end
              end
        end
        
        if fromLocation.typ == URL_STORAGE_FS
          if File.exist?(fromFile) 
             FileUtils.cp(fromFile, toFile)
             n = n +1
          end
        end
        
     end
     
   end
   return n.to_s+ " files copied"
 end

# delete all files in the location' filesystem
 def self.deleteFiles(location)
   storage = location.storage
   typ = location.typ
   
   return ["wrong type",0] unless typ == URL_STORAGE_FS  or typ == URL_STORAGE_FSTN
   
   folders = storage.folders
   
   n = 0 
   del = 0
   
   folders.each do |folder|
     
     mfiles = folder.mfiles
     
     mfiles.each do |mfile|
       n = n + 1
       prefix = location.prefix || ""
       path = File.join(location.uri, folder.mpath, folder.lfolder, prefix+mfile.filename)
       if File.exist?(path)
         File.delete(path)
         del = del + 1
       end
     end
   end
   
   [n, del]
   
 end

 def self.generateTNs(fromLocation, toLocation, force=true, prefix, area)
   
   storage = toLocation.storage
   return "different storages" unless fromLocation.storage == storage
   toUri = toLocation.uri
   fromUri = fromLocation.uri
# check types
   return "wrong typ in fromLocation"  unless fromLocation.typ == URL_STORAGE_FS  
   return "wrong typ in toLocation"    unless toLocation.typ == URL_STORAGE_FSTN
   
# get all folder from storage - fromLocation

   folders = storage.folders
   n = 0
   
   folders.each do |folder|
     from = File.join(fromUri, folder.mpath, folder.lfolder)
     to =   File.join(toUri, folder.mpath, folder.lfolder)
     
     mfiles = folder.mfiles
     
     mfiles.each do |mfile|
        tofile = File.join(to,prefix+mfile.filename)
        next unless force or !File.exist?(tofile)  # 
        
        fromfile = File.join(from,mfile.filename)
 
 #       fromfile = UriHandler.cesc(fromfile)
 #       tofile = UriHandler.cesc(tofile)
        
        
        case 
        when mfile.pic?
           if area == 0 
              command = "jhead -st \"" + tofile + "\"  \"" + fromfile  +"\""
           else
              command = "convert \""+ fromfile + "\" -thumbnail "+area.to_s+"@ \""+ tofile+"\""
           end
        when mfile.pdf?
              tofile = tofile.gsub(".pdf",".jpg").gsub(".PDF",".jpg")
              are = (area==0)?20000:area
              command = "convert \""+File.join(from,mfile.filename)+ "\"[0] -thumbnail "+are.to_s+"@ \""+ tofile+"\""
        else 
             command = nil
        end
        
        if command
           puts command
           system(command)
        end
        n = n + 1
     end
   end
   return n.to_s+" thumbnails generated"
 end

# check the Content
 def self.checkContent(location)
   
   storage = location.storage
   typ = location.typ
   
   folders = storage.folders
   
   n = 0
   avail = 0
   
   folders.each do |folder|
     
     mfiles = folder.mfiles
     
     mfiles.each do |mfile|
       n = n + 1
       prefix = location.prefix || ""
       path = File.join(location.uri, folder.mpath, folder.lfolder, prefix+mfile.filename)
       path = path.gsub("//", "/").gsub(":/","://")
       
       puts path    
       if typ == URL_STORAGE_FS  or typ == URL_STORAGE_FSTN
           avail = avail + 1 if File.exist?(path)
       end       
       if typ == URL_WEB  or typ == URL_STORAGE_WEB or typ == URL_STORAGE_WEBTN
         
 #          begin 
 #             open( path, :method => :head).status
 #             avail = avail + 1
 #             rescue StandardError
 #          end
             
#          begin
#              response = Net::HTTP.get_response(URI.parse(path))
#              puts response.value
#              if response.kind_of? Net::HTTPSuccess
#                 avail = avail + 1
#              end
#           rescue StandardError
#           end

          begin
              uri = URI.parse(path)
              response = nil
              Net::HTTP.start(uri.host, uri.port) do |http|
                 puts "11111111"
                 response = http.head(uri.path)
                 puts  "222222222222"
              end
              puts "3333333333333"
              if response.kind_of? Net::HTTPSuccess
                 avail = avail + 1
              end
           rescue StandardError
             puts "error"
           end

       end 
     end
   end   
   [n,avail]
 end

 def self.checkAvail(location)
   
     ltyp = location.typ
     
     if ltyp == URL_WEB  or ltyp == URL_STORAGE_WEB or ltyp == URL_STORAGE_WEBTN
           
           @title = "Site is not available"
           begin
              response = Net::HTTP.get_response(URI.parse(location.uri))
              puts response.value
              if response.kind_of? Net::HTTPSuccess
                 @title = "Site is available"
              end
           rescue StandardError
           end    
     end
     
     if ltyp == URL_STORAGE_FS or ltyp == URL_STORAGE_FSTN 
       puts location.uri
       if File.exist?(location.uri)
          @title = "Directory is there"
       else
          @title = "Directory does not exist"
       end
     end
     
     @title
   
 end

#######################################
# Escape of ' for OS commonas
def self.cesc(f)
  
  f.gsub("'", "\\'")
end


end
