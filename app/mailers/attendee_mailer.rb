class AttendeeMailer < ApplicationMailer
  default from: 'info@blackbirdrsvp.com'
  
  def qr_code_email(attendee)
    @attendee = attendee
    @event = attendee.event
    
    # Generate QR code as PNG
    qr_code_png = @attendee.generate_qr_code
    
    # Attach QR code image
    attachments["#{@attendee.full_name.parameterize}-qr-code.png"] = qr_code_png.to_s
    
    mail(
      to: @attendee.email,
      subject: "Your QR Code for #{@event.name}",
      template_name: 'qr_code_email'
    )
  end
  
  def resend_qr_code(attendee)
    qr_code_email(attendee)
  end
end