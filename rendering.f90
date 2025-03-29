! Fortran module to define the interface
module c_interface
    use, intrinsic :: iso_c_binding
    implicit none

    interface
        subroutine post_process(img, height, width, filename) bind(c, name="post_process")
          use iso_c_binding
          character(kind=c_char), intent(in) :: filename(*)
          integer(c_int), intent(in) :: height, width
          type(c_ptr), value, intent(in) :: img     
        end subroutine post_process
    end interface
end module c_interface

module rendering
  use, intrinsic :: iso_c_binding
  implicit none
  
  real, allocatable, target :: image(:,:,:)
  
  integer :: file_unit, i

contains
  subroutine initialize_image(height, width)
    integer, intent(in) :: width, height
    
    allocate(image(4, height, width))
  end subroutine initialize_image
  
  subroutine stack_image(other_image)
    real, intent(in) :: other_image(:,:,:)
    image = image + other_image
  end subroutine stack_image
  
  subroutine draw_point(point, color, image)
    complex, intent(in) :: point
    real, intent(in) :: color(3)
    real, intent(inout) :: image(:,:,:)
    integer :: x, y

    ! Get width and height from image shape
    integer :: height, width
    height = size(image, 2)
    width = size(image, 3)

    x = int(real(point))
    y = int(aimag(point))

    if (y > 0 .and. y <= height .and. x > 0 .and. x <= width) then
       ! Add color to RGB channels, and add 1 to alpha channel
        image(:, y, x) = image(:, y, x) + (/color(1), color(2), color(3), 1.0/)
    endif

  end subroutine draw_point

  subroutine write_image(filename, gain, gamma, invert, bg_color)
    use c_interface
    implicit none
    
    character(len=*, kind=c_char), intent(in) :: filename
    real, intent(in) :: gain
    real, intent(in) :: gamma
    logical, intent(in) :: invert
    real, intent(in) :: bg_color(3)

    integer :: height, width, c

    ! Get width and height from image shape
    height = size(image, 2)
    width = size(image, 3)

    ! Normalize the image (color channels only)
    image(1:3, :, :) = image(1:3, :, :) / maxval(image(1:3, :, :))

    ! Normalize alpha channel
    image(4, :, :) = image(4, :, :) / maxval(image(4, :, :))

    ! Gamma correction
    image(1:3, :, :) = image(1:3, :, :) ** (1.0 / gamma)

    if (invert) then
       ! Perform subtractive color mixing (inverting the image)
       image(1:3, :, :) = 1.0 - image(1:3, :, :)
    end if

    ! Apply alpha gain
    image(4, :, :) = image(4, :, :) * gain

    do c = 1, 3
       image(c, :, :) = image(c, :, :) * image(4, :, :) + bg_color(c) * (1.0 - image(4, :, :))
    end do

    ! Set alpha to 1
    image(4, :, :) = 1.0

    print *, "Writing image to ", filename
    ! Call C function to write the image
    call post_process(c_loc(image), height, width, filename)
  end subroutine write_image



  
end module rendering

