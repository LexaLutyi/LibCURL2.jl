using LibCURL2
using LibCURL2_jll
using Test


# Setup the callback function to recv data
function curl_write_cb(curlbuf::Ptr{Cvoid}, s::Csize_t, n::Csize_t, p_ctxt::Ptr{Cvoid})
    sz = s * n
    return sz::Csize_t
end

c_curl_write_cb = @cfunction(
    curl_write_cb,
    Csize_t,
    (Ptr{Cvoid}, Csize_t, Csize_t, Ptr{Cvoid})
)


@testset "LibCURL2_jll" begin
    curl = @ccall libcurl.curl_easy_init()::Ptr{Cvoid}
    # set url
    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_URL::UInt64, "https://www.google.com"::Cstring)::CURLcode
    # set callback
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)
    # set ssl
    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_USE_SSL::UInt64, CURLUSESSL_ALL::UInt64)::CURLcode
    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_SSL_VERIFYHOST::UInt64, 2::UInt64)::CURLcode
    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_SSL_VERIFYPEER::UInt64, 1::UInt64)::CURLcode
    @ccall libcurl.curl_easy_setopt(curl::Ptr{Cvoid}, CURLOPT_CAINFO::UInt64, LibCURL2.cacert::Cstring)::CURLcode
    # perform
    code = @ccall libcurl.curl_easy_perform(curl::Ptr{Cvoid})::CURLcode
    # code as str
    str_ptr = @ccall libcurl.curl_easy_strerror(code::CURLcode)::Ptr{UInt8}
    str = unsafe_string(str_ptr)

    @test code == CURLE_OK
    @test str == "No error"
end


function set_ssl(curl)
    curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2)
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1)
    curl_easy_setopt(curl, CURLOPT_CAINFO, LibCURL2.cacert)
end


@testset "minimal example" begin
    curl = curl_easy_init()
    curl == C_NULL && error("curl_easy_init() failed")

    curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    set_ssl(curl)
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

    code = curl_easy_perform(curl)
    str = unsafe_string(curl_easy_strerror(code))
    @test code == CURLE_OK
    @test str == "No error"
    curl_easy_cleanup(curl)
end

@testset "curl url" begin
    url = "https://www.google.com/search?q=abc"
    curl = curl_easy_init()
    curl == C_NULL && error("curl_easy_init() failed")

    # curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    c_url = curl_url()
    curl_url_set(c_url, CURLUPART_URL, url, CURLU_DEFAULT_SCHEME)
    curl_easy_setopt(curl, CURLOPT_CURLU, c_url)

    set_ssl(curl)
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

    code = curl_easy_perform(curl)
    str = unsafe_string(curl_easy_strerror(code))
    @test code == CURLE_OK
    @test str == "No error"
    curl_easy_cleanup(curl)
end


@testset "curl url" begin
    url = "https://www.google.com/search?q=abc"
    curl = curl_easy_init()
    curl == C_NULL && error("curl_easy_init() failed")

    # curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    c_url = curl_url()
    curl_url_set(c_url, CURLUPART_URL, url, CURLU_DEFAULT_SCHEME)
    curl_easy_setopt(curl, CURLOPT_CURLU, c_url)

    set_ssl(curl)
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

    code = curl_easy_perform(curl)
    str = unsafe_string(curl_easy_strerror(code))
    @test code == CURLE_OK
    @test str == "No error"
    curl_easy_cleanup(curl)
end


@testset "interface" begin
    url = "https://www.google.com/search?q=abc"
    curl = curl_easy_init()
    curl == C_NULL && error("curl_easy_init() failed")

    # curl_easy_setopt(curl, CURLOPT_URL, "https://www.google.com")
    c_url = curl_url()
    curl_url_set(c_url, CURLUPART_URL, url, CURLU_DEFAULT_SCHEME)
    curl_easy_setopt(curl, CURLOPT_CURLU, c_url)

    set_ssl(curl)
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, c_curl_write_cb)

    interface = Ptr{UInt8}(0)
    curl_easy_setopt(curl, CURLOPT_INTERFACE, interface)

    code = curl_easy_perform(curl)
    str = unsafe_string(curl_easy_strerror(code))
    @test code == CURLE_OK
    @test str == "No error"
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
