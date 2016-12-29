module fvs_wrap
    use iso_c_binding

    implicit none

    contains

    pure function f2c_string(f_str) result(c_str)
        ! Convert from a fortran string to a C string
        ! From http://fortranwiki.org/fortran/show/Generating+C+Interfaces
        use, intrinsic :: iso_c_binding, only: c_char, c_null_char
        implicit none
        character(len=*), intent(in) :: f_str
        character(kind=c_char, len=1) :: c_str(len_trim(f_str)+1)
        integer i,n

        n = len_trim(f_str)
        do i=1,n
            c_str(i:i) = f_str(i:i)
        end do
        c_str(n+1:n+1) = c_null_char

        !c_str = f_str // c_null_char

    end function f2c_string

    subroutine version(ver) bind(c, name='version')
        character(kind=c_char, len=1) :: ver(7)

        ver = f2c_string('0.0.0a0')

    end subroutine version

end module fvs_wrap

