module functions
  implicit none

  real, parameter :: PI = 3.14159

contains

  complex function ring(point, n, radius, ratio)
    complex, intent(in) :: point
    integer, intent(in) :: n
    real, intent(in) :: radius
    real, intent(in) :: ratio

    complex :: target_point

    real :: r, theta
    integer :: i

    call random_number(r)
    i = int(r * n)
    theta = 2 * PI / n * i

    target_point = cmplx(cos(theta) * radius, sin(theta) * radius)

    ring = (point + target_point) * ratio
  end function ring

  complex function unit_rand()
    real :: r(2)
    call random_number(r)
    unit_rand = cmplx(r(1), r(2)) * 2 - 1
  end function unit_rand

  real function magnitude(point)
    complex, intent(in) :: point
    magnitude = sqrt(real(point)**2 + aimag(point)**2)
  end function magnitude

  complex function normalize(point)
    complex, intent(in) :: point
    normalize = point / magnitude(point)
  end function normalize

  complex function rotate(point, theta, about)
    complex, intent(in) :: point, about
    real, intent(in) :: theta
    ! rotate = point * cmplx(cos(theta), sin(theta))
    rotate = (point - about) * cmplx(cos(theta), sin(theta)) + about
  end function rotate

  complex function translate(point, dx, dy)
    complex, intent(in) :: point
    real, intent(in) :: dx
    real, intent(in) :: dy
    translate = point + cmplx(dx, dy)
  end function translate

  complex function scale(point, xscale, yscale, about)
    complex, intent(in) :: point, about
    real, intent(in) :: xscale
    real, intent(in) :: yscale
    scale = (point - about) * cmplx(xscale, yscale) + about
  end function scale

  real function angle(point)
    complex, intent(in) :: point
    angle = atan2(aimag(point), real(point))
  end function angle

end module functions
