using LibCURL2
using Test


# Setup the callback function to recv data
function curl_write_cb(curlbuf::Ptr{Cvoid}, s::Csize_t, n::Csize_t, p_ctxt::Ptr{Cvoid})
    sz = s * n
    data = Array{UInt8}(undef, sz)
    ccall(:memcpy, Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), data, curlbuf, sz)
    return sz::Csize_t
end


@testset "LibCURL2.jl" begin
    curl = curl_easy_init()
    curl == C_NULL && error("curl_easy_init() failed")
    

    # Set up the write function to consume the curl output so we don't see it in the
    # test output
    c_curl_write_cb = @cfunction(
        curl_write_cb,
        Csize_t,
        (Ptr{Cvoid}, Csize_t, Csize_t, Ptr{Cvoid})
    )
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

    # Set up our SSL options
    curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1)
    curl_easy_setopt(curl, CURLOPT_CAINFO, LibCURL2.cacert)

    @testset "SSL Success" begin
        res = curl_easy_perform(curl)
        @test res == CURLE_OK
    end
    
    curl_easy_cleanup(curl)
end


# @testset "Headers" begin
#     prev = Ptr{HttpClient.CurlHeader}(0)
#     @test prev == C_NULL
#     curl = setup_curl_for_reading()
#     next_header_ptr = HttpClient.curl_easy_nextheader(curl, HttpClient.CURLH_HEADER, 0, prev)
#     @test next_header_ptr != C_NULL
#     next_header = unsafe_load(next_header_ptr)
#     @test typeof(next_header) == HttpClient.CurlHeader

#     c_headers = HttpClient.extract_c_headers(curl)
#     @test typeof(c_headers) == Vector{HttpClient.CurlHeader}
#     @test length(c_headers) > 0

#     headers = c_headers .|> HttpClient.name_and_value |> Dict
#     @test headers["Content-Type"] == "text/html; charset=UTF-8"
#     @test headers["Content-Length"] == "1256"

#     @test headers == HttpClient.extract_headers(curl)
# end