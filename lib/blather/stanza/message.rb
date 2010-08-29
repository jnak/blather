require "time"

module Blather
class Stanza

  # # Message Stanza
  #
  # [RFC 3921 Section 2.1 - Message Syntax](http://xmpp.org/rfcs/rfc3921.html#rfc.section.2.1)
  #
  # Exchanging messages is a basic use of XMPP and occurs when a user
  # generates a message stanza that is addressed to another entity. The
  # sender's server is responsible for delivering the message to the intended
  # recipient (if the recipient is on the same local server) or for routing
  # the message to the recipient's server (if the recipient is on a remote
  # server). Thus a message stanza is used to "push" information to another
  # entity.
  #
  # ## "To" Attribute
  #
  # An instant messaging client specifies an intended recipient for a message
  # by providing the JID of an entity other than the sender in the `to`
  # attribute of the Message stanza. If the message is being sent outside the
  # context of any existing chat session or received message, the value of the
  # `to` address SHOULD be of the form "user@domain" rather than of the form
  # "user@domain/resource".
  #
  #     msg = Message.new 'user@domain.tld/resource'
  #     msg.to == 'user@domain.tld/resource'
  #
  #     msg.to = 'another-user@some-domain.tld/resource'
  #     msg.to == 'another-user@some-domain.tld/resource'
  #
  # The `to` attribute on a Message stanza works like any regular ruby object
  # attribute
  #
  # ## "Type" Attribute
  #
  # Common uses of the message stanza in instant messaging applications
  # include: single messages; messages sent in the context of a one-to-one
  # chat session; messages sent in the context of a multi-user chat room;
  # alerts, notifications, or other information to which no reply is expected;
  # and errors. These uses are differentiated via the `type` attribute. If
  # included, the `type` attribute MUST have one of the following values:
  #
  # * `:chat` -- The message is sent in the context of a one-to-one chat
  #   session. Typically a receiving client will present message of type
  #   `chat` in an interface that enables one-to-one chat between the two
  #   parties, including an appropriate conversation history.
  #
  # * `:error` -- The message is generated by an entity that experiences an
  #   error in processing a message received from another entity. A client
  #   that receives a message of type `error` SHOULD present an appropriate
  #   interface informing the sender of the nature of the error.
  #
  # * `:groupchat` -- The message is sent in the context of a multi-user chat
  #   environment (similar to that of [IRC]). Typically a receiving client
  #   will present a message of type `groupchat` in an interface that enables
  #   many-to-many chat between the parties, including a roster of parties in
  #   the chatroom and an appropriate conversation history.
  #
  # * `:headline` -- The message provides an alert, a notification, or other
  #   information to which no reply is expected (e.g., news headlines, sports
  #   updates, near-real-time market data, and syndicated content). Because no
  #   reply to the message is expected, typically a receiving client will
  #   present a message of type "headline" in an interface that appropriately
  #   differentiates the message from standalone messages, chat messages, or
  #   groupchat messages (e.g., by not providing the recipient with the
  #   ability to reply).
  #
  # * `:normal` -- The message is a standalone message that is sent outside
  #   the context of a one-to-one conversation or groupchat, and to which it
  #   is expected that the recipient will reply. Typically a receiving client
  #   will present a message of type `normal` in an interface that enables the
  #   recipient to reply, but without a conversation history. The default
  #   value of the `type` attribute is `normal`.
  #
  # Blather provides a helper for each possible type:
  #
  #     Message#chat?
  #     Message#error?
  #     Message#groupchat?
  #     Message#headline?
  #     Message#normal?
  #
  # Blather treats the `type` attribute like a normal ruby object attribute
  # providing a getter and setter. The default `type` is `chat`.
  #
  #     msg = Message.new
  #     msg.type              # => :chat
  #     msg.chat?             # => true
  #     msg.type = :normal
  #     msg.normal?           # => true
  #     msg.chat?             # => false
  #
  #     msg.type = :invalid   # => RuntimeError
  #
  #
  # ## "Body" Element
  #
  # The `body` element contains human-readable XML character data that
  # specifies the textual contents of the message; this child element is
  # normally included but is optional.
  #
  # Blather provides an attribute-like syntax for Message `body` elements.
  #
  #     msg = Message.new 'user@domain.tld', 'message body'
  #     msg.body  # => 'message body'
  #
  #     msg.body = 'other message'
  #     msg.body  # => 'other message'
  #
  # ## "Subject" Element
  #
  # The `subject` element contains human-readable XML character data that
  # specifies the topic of the message.
  #
  # Blather provides an attribute-like syntax for Message `subject` elements.
  #
  #     msg = Message.new 'user@domain.tld', 'message body'
  #     msg.subject = 'message subject'
  #     msg.subject  # => 'message subject'
  #
  # ## "Thread" Element
  #
  # The primary use of the XMPP `thread` element is to uniquely identify a
  # conversation thread or "chat session" between two entities instantiated by
  # Message stanzas of type `chat`. However, the XMPP thread element can also
  # be used to uniquely identify an analogous thread between two entities
  # instantiated by Message stanzas of type `headline` or `normal`, or among
  # multiple entities in the context of a multi-user chat room instantiated by
  # Message stanzas of type `groupchat`. It MAY also be used for Message
  # stanzas not related to a human conversation, such as a game session or an
  # interaction between plugins. The `thread` element is not used to identify
  # individual messages, only conversations or messagingg sessions. The
  # inclusion of the `thread` element is optional.
  #
  # The value of the `thread` element is not human-readable and MUST be
  # treated as opaque by entities; no semantic meaning can be derived from it,
  # and only exact comparisons can be made against it. The value of the
  # `thread` element MUST be a universally unique identifier (UUID) as
  # described in [UUID].
  #
  # The `thread` element MAY possess a 'parent' attribute that identifies
  # another thread of which the current thread is an offshoot or child; the
  # value of the 'parent' must conform to the syntax of the `thread` element
  # itself.
  #
  # Blather provides an attribute-like syntax for Message `thread` elements.
  #
  #     msg = Message.new
  #     msg.thread = '12345'
  #     msg.thread                                  # => '12345'
  #
  # Parent threads can be set using a hash:
  #
  #     msg.thread = {'parent-id' => 'thread-id'}
  #     msg.thread                                  # => 'thread-id'
  #     msg.parent_thread                           # => 'parent-id'
  #
  # @handler :message
  class Message < Stanza
    VALID_TYPES = [:chat, :error, :groupchat, :headline, :normal].freeze

    HTML_NS = 'http://jabber.org/protocol/xhtml-im'.freeze
    HTML_BODY_NS = 'http://www.w3.org/1999/xhtml'.freeze

    register :message

    # @private
    def self.import(node)
      klass = nil
      node.children.detect do |e|
        ns = e.namespace ? e.namespace.href : nil
        klass = class_from_registration(e.element_name, ns)
      end
      
      if klass && klass != self
        klass.import(node)
      else
        new(node[:type]).inherit(node)
      end
    end

    # Create a new Message stanza
    #
    # @param [#to_s] to the JID to send the message to
    # @param [#to_s] body the body of the message
    # @param [Symbol] type the message type. Must be one of VALID_TYPES
    def self.new(to = nil, body = nil, type = :chat)
      node = super :message
      node.to = to
      node.type = type
      node.body = body
      node
    end

    # Check if the Message is of type :chat
    #
    # @return [true, false]
    def chat?
      self.type == :chat
    end

    # Check if the Message is of type :error
    #
    # @return [true, false]
    def error?
      self.type == :error
    end

    # Check if the Message is of type :groupchat
    #
    # @return [true, false]
    def groupchat?
      self.type == :groupchat
    end

    # Check if the Message is of type :headline
    #
    # @return [true, false]
    def headline?
      self.type == :headline
    end

    # Check if the Message is of type :normal
    #
    # @return [true, false]
    def normal?
      self.type == :normal
    end

    # Ensures type is :get, :set, :result or :error
    #
    # @param [#to_sym] type the Message type. Must be one of VALID_TYPES
    def type=(type)
      if type && !VALID_TYPES.include?(type.to_sym)
        raise ArgumentError, "Invalid Type (#{type}), use: #{VALID_TYPES*' '}"
      end
      super
    end

    # Get the message body
    #
    # @return [String]
    def body
      read_content :body
    end

    # Set the message body
    #
    # @param [#to_s] body the message body
    def body=(body)
      set_content_for :body, body
    end

    # Get the message xhtml node
    # This will create the node if it doesn't exist
    #
    # @return [XML::Node]
    def xhtml_node
      unless h = find_first('ns:html', :ns => HTML_NS)
        self << (h = XMPPNode.new('html', self.document))
        h.namespace = HTML_NS
      end

      unless b = h.find_first('ns:body', :ns => HTML_BODY_NS)
        h << (b = XMPPNode.new('body', self.document))
        b.namespace = HTML_BODY_NS
      end

      b
    end

    # Get the message xhtml
    #
    # @return [String]
    def xhtml
      self.xhtml_node.to_xhtml
    end

    # Set the message xhtml
    # This will use Nokogiri to ensure the xhtml is valid
    #
    # @param [#to_s] valid xhtml
    def xhtml=(xhtml_body)
      xhtml_body = Nokogiri::HTML.fragment(xhtml_body)
      self.xhtml_node << xhtml_body
    end

    # Get the message subject
    #
    # @return [String]
    def subject
      read_content :subject
    end

    # Set the message subject
    #
    # @param [#to_s] body the message subject
    def subject=(subject)
      set_content_for :subject, subject
    end

    # Get the message thread
    #
    # @return [String]
    def thread
      read_content :thread
    end

    # Get the parent thread
    #
    # @return [String, nil]
    def parent_thread
      n = find_first('thread')
      n[:parent] if n
    end

    # Set the thread
    #
    # @overload thread=(hash)
    #   Set a thread with a parent
    #   @param [Hash<parent-id => thread-id>] thread
    # @overload thread=(thread)
    #   Set a thread id
    #   @param [#to_s] thread the new thread id
    def thread=(thread)
      parent, thread = thread.to_a.flatten if thread.is_a?(Hash)
      set_content_for :thread, thread
      find_first('thread')[:parent] = parent
    end
    
    def delay=(value)
      unless b = find_first('ns:x', :ns => 'jabber:x:delay')
        h << (b = XMPPNode.new('ns:x', self.document))
        b.namespace = 'jabber:x:delay'
      end
      b[:stamp] = value
    end
    
    def delay
      delay = find_first('ns:x', :ns => 'jabber:x:delay')
      stamp = delay && delay[:stamp]
      return unless stamp
      # Make sure time is UTC
      stamp += "Z" unless stamp[-1..-1] == "Z"
      Time.parse(stamp)
    end
  end

end
end