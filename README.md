# IPSEC CALICO Helper

This container will add a route to an endpoint of a defined service.
It is necessary in the context of calcio to add the route into the host namespace,
and allow calcio to propagate this route onto other hosts, if enabled.

Therefore pods and services can also be reached from the other side of the tunnel.

## Configuration parameters as ENV variables

* `IPSEC_REMOTENET` - remote network which should be routed
* `IPSEC_SERVICE` - service name of the IPSEC service, over which the traffic shall be routed
