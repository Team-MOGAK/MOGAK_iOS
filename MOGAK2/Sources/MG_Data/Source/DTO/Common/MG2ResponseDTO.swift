/// 서버 공통 응답 `{ "result": ... }`
struct MG2ResponseDTO<Value: Decodable>: Decodable {
    let result: Value
}

/// `result`가 null이거나 없을 수 있는 응답
struct MG2OptionalResponseDTO<Value: Decodable>: Decodable {
    let result: Value?
}
