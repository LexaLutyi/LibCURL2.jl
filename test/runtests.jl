using LibCURL2
using LibCURL2_jll
using Test


@testset "Local LibCURL2_jll" begin
    # const CURLOPT_URL = 10002 % UInt32
    # const CURLcode = UInt32
    # const CURLE_OK = 0 % UInt32

    curl = @ccall libcurl.curl_easy_init()::Ptr{Cvoid}

    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_URL::UInt64, "https://www.google.com"::Cstring)::CURLcode

    req = @ccall libcurl.curl_easy_perform(curl::Ptr{Cvoid})::CURLcode

    @show req
    err = @ccall libcurl.curl_easy_strerror(req::CURLcode)::Ptr{UInt8}
    err |> unsafe_string |> println
end


@testset "Minimal example" begin
    curl = curl_easy_init()
    curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    req = curl_easy_perform(curl)
    @show req
    curl_easy_cleanup(curl)
end


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
    

#     # Set up the write function to consume the curl output so we don't see it in the
#     # test output
    # c_curl_write_cb = @cfunction(
    #     curl_write_cb,
    #     Csize_t,
    #     (Ptr{Cvoid}, Csize_t, Csize_t, Ptr{Cvoid})
    # )
    # curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

#     # Set up our SSL options
    curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1)
    curl_easy_setopt(curl, CURLOPT_CAINFO, LibCURL2.cacert)

    @testset "SSL Success" begin
        res = curl_easy_perform(curl)
        @test res == CURLE_OK
        # curl_error = unsafe_string(curl_easy_strerror(rc))
        # error(curl_error)
    end
    curl_easy_cleanup(curl)
end


function print_protocols()
    v = curl_version_info(CURLVERSION_NOW)
    v2 = unsafe_load(v, 1)
    v2.version |> unsafe_string |> println
    for i in 1:30
        p = unsafe_load(v2.protocols, i)
        if p == C_NULL
            break
        end
        p |> unsafe_string |> println
    end
end

print_protocols()