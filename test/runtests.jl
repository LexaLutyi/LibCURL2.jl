using LibCURL2
using Test

@testset "LibCURL2.jl" begin
    curl = curl_easy_init()
    @show curl_easy_setopt(curl, CURLOPT_URL, "https://example.com")
    res = curl_easy_perform(curl)
    if res != CURLE_OK
        curl_error = unsafe_string(curl_easy_strerror(res))
        error(curl_error)
    end
    curl_easy_cleanup(curl)
end
