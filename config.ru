Dir[File.dirname(__FILE__)+"/lib/*.rb"].each {|file| require file }

map "/wufoo" do run WIDGET::Wufoo end
map "/ooyala" do run WIDGET::OoyalaAPI end
map "/feedpress" do run WIDGET::FeedpressAPI end


