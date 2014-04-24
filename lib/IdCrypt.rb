class IdCrypt

  def initialize()
    @last_id = 0
    @encoded_id = 0
  end

  # the encode and decode algorithms come from Michael Greenly's blog:
  # http://blog.michaelgreenly.com/2008/01/obsificating-ids-in-urls.html.
  MAXID = 2147483647  # (2**31 - 1)
  PRIME = 1580030173  # number suggested on the blog
  PRIME_INVERSE = 59260789 # (PRIME * PRIME_INVERSE) & MAXID == 1

  # encode the given id
  def encode_id( clear_id )
    if clear_id
      id_int = Integer( clear_id )  # ensure that the id is an integer
      if @last_id != id_int
        @last_id       = id_int
        @encoded_id = (id_int * PRIME) & MAXID
      end
    else
      @encoded_id = clear_id
    end
    @encoded_id
  end

  # reverse the obfuscation that was applied to the given id
  def self.decode_id( encoded_id )
    clear_id = 0
    if encoded_id && (encoded_id != "")
      clear_id = (Integer(encoded_id) * PRIME_INVERSE) & MAXID
    end
    clear_id
  end

  # reverse the obfuscation that was applied to the given param symbol
  def self.decode_param( symbol )
    params[symbol] = IdCrypt::decode_id(symbol).to_s if params[symbol]
  end
end