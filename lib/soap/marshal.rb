# SOAP4R - Marshalling/Unmarshalling Ruby's object using SOAP Encoding.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require "soap/mapping"
require "soap/processor"


module SOAP


module Marshal
  # Trying xsd:dateTime data to be recovered as aTime.
  MarshalMappingRegistry = Mapping::EncodedRegistry.new(
    :allow_original_mapping => true)
  MarshalMappingRegistry.add(
    Time,
    ::SOAP::SOAPDateTime,
    ::SOAP::Mapping::EncodedRegistry::DateTimeFactory
  )

  class << self
  public
    def dump(obj, io = nil)
      marshal(obj, MarshalMappingRegistry, io)
    end

    def load(stream)
      unmarshal(stream, MarshalMappingRegistry)
    end

    def marshal(obj, mapping_registry = MarshalMappingRegistry, io = nil)
      elename = Mapping.name2elename(obj.class.to_s)
      soap_obj = Mapping.obj2soap(obj, mapping_registry)
      body = SOAPBody.new
      body.add(elename, soap_obj)
      env = SOAPEnvelope.new(nil, body)
      SOAP::Processor.marshal(env, {}, io)
    end

    def unmarshal(stream, mapping_registry = MarshalMappingRegistry)
      env = SOAP::Processor.unmarshal(stream)
      if env.nil? or !env.is_a?(::SOAP::SOAPEnvelope)
	raise ArgumentError.new("Illegal SOAP marshal format.")
      end
      Mapping.soap2obj(env.body.root_node, mapping_registry)
    end
  end
end


end


SOAPMarshal = SOAP::Marshal
