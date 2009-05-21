# soap/attachment.rb: SOAP4R - SwA implementation.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping'


module SOAP


class SOAPAttachment < SOAPExternalReference
  attr_reader :data

  def initialize(value)
    super()
    @data = value
  end

private

  def external_contentid
    @data.contentid
  end
end


class Attachment
  attr_reader :io
  attr_accessor :contenttype

  def initialize(string_or_readable = nil)
    @string_or_readable = string_or_readable
    @contenttype = "application/octet-stream"
    @contentid = nil
    @content = nil
  end

  def contentid
    @contentid ||= Attachment.contentid(self)
  end

  def contentid=(contentid)
    @contentid = contentid
  end

  def mime_contentid
    '<' + contentid + '>'
  end

  def content
    if @content == nil and @string_or_readable != nil
      if @string_or_readable.respond_to?(:read)
        @content = @string_or_readable.read
      else
        @content = @string_or_readable
      end
    end
    @content
  end

  def to_s
    content
  end

  def write(out)
    out.write(content)
  end

  def save(filename)
    File.open(filename, "wb") do |f|
      write(f)
    end
  end

  def self.contentid(obj)
    # this needs to be fixed
    [obj.__id__.to_s, Process.pid.to_s].join('.')
  end
end


module Mapping
  class AttachmentFactory < SOAP::Mapping::Factory
    def obj2soap(soap_class, obj, info, map)
      soap_obj = soap_class.new(obj)
      mark_marshalled_obj(obj, soap_obj)
      soap_obj
    end

    def soap2obj(obj_class, node, info, map)
      obj = node.data
      mark_unmarshalled_obj(node, obj)
      return true, obj
    end
  end

  DefaultRegistry.add(::SOAP::Attachment, ::SOAP::SOAPAttachment,
    AttachmentFactory.new, nil)
end


end
