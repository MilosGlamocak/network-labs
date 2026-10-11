#!/bin/bash
# Lab 2: ROAS - verifikacija
# Pokretanje: ./verify.sh  (exit kod 0 = sve prošlo, 1 = bar jedna provjera pala)

FAILED=0

# check <host> <cilj> <očekivani TTL>
# TTL 64 = odgovara direktno R1 (gateway), TTL 63 = paket je prošao kroz R1 (rutiranje)
check() {
    local src=$1 dst=$2 ttl=$3
    local out
    out=$(docker exec "clab-roas-$src" ping -c 2 -W 1 "$dst" 2>&1)
    if [ $? -eq 0 ] && echo "$out" | grep -q "ttl=$ttl"; then
        echo "PASS: $src -> $dst (ttl=$ttl)"
    else
        echo "FAIL: $src -> $dst (očekivan ttl=$ttl)"
        FAILED=1
    fi
}

echo "== Gateway checks =="
check host10 10.0.10.1 64
check host20 10.0.20.1 64
check host30 10.0.30.1 64

echo "== Inter-VLAN routing =="
check host10 10.0.20.10 63
check host20 10.0.30.10 63
check host30 10.0.10.10 63

if [ "$FAILED" -eq 0 ]; then
    echo "ALL CHECKS PASSED"
else
    echo "SOME CHECKS HAVE FAILED"
fi
exit $FAILED