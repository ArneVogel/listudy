function string_hash(s) {
    const reducer = (acc, value) => (acc + value.charCodeAt(0) || 0) % 100000;

    return s.split("").reduce(reducer);
}

export { string_hash }
