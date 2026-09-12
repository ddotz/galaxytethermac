#include "network_policy.h"
#include <SystemConfiguration/SystemConfiguration.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netinet/in.h>
#include <string.h>

static int usable_address(const struct sockaddr *address)
{
    if (!address) return 0;
    if (address->sa_family == AF_INET) {
        uint32_t ip = ntohl(((const struct sockaddr_in *)address)->sin_addr.s_addr);
        return ip != 0 && (ip >> 24) != 127 && (ip >> 16) != 0xa9fe;
    }
    if (address->sa_family == AF_INET6) {
        const struct in6_addr *ip = &((const struct sockaddr_in6 *)address)->sin6_addr;
        return !IN6_IS_ADDR_UNSPECIFIED(ip) && !IN6_IS_ADDR_LOOPBACK(ip) &&
               !IN6_IS_ADDR_LINKLOCAL(ip) && !IN6_IS_ADDR_MULTICAST(ip);
    }
    return 0;
}

int network_other_connected(char *interface_name, size_t capacity)
{
    if (interface_name && capacity) interface_name[0] = '\0';
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("GalaxyTetherMac"), NULL);
    SCDynamicStoreRef store = SCDynamicStoreCreate(NULL, CFSTR("GalaxyTetherMac"), NULL, NULL);
    struct ifaddrs *addresses = NULL;
    if (!prefs || !store || getifaddrs(&addresses) != 0) {
        if (prefs) CFRelease(prefs);
        if (store) CFRelease(store);
        return -1;
    }
    CFArrayRef services = SCNetworkServiceCopyAll(prefs);
    int result = services ? 0 : -1;
    for (CFIndex i = 0; services && i < CFArrayGetCount(services); i++) {
        SCNetworkServiceRef service = (SCNetworkServiceRef)CFArrayGetValueAtIndex(services, i);
        if (!SCNetworkServiceGetEnabled(service)) continue;
        SCNetworkInterfaceRef iface = SCNetworkServiceGetInterface(service);
        if (!iface) continue;
        CFStringRef type = SCNetworkInterfaceGetInterfaceType(iface);
        CFStringRef bsd = SCNetworkInterfaceGetBSDName(iface);
        if (!type || !bsd) continue;
        if (!CFEqual(type, kSCNetworkInterfaceTypeEthernet) &&
            !CFEqual(type, kSCNetworkInterfaceTypeIEEE80211) &&
            !CFEqual(type, kSCNetworkInterfaceTypeFireWire) &&
            !CFEqual(type, CFSTR("Bridge"))) continue;
        char name[IFNAMSIZ];
        if (!CFStringGetCString(bsd, name, sizeof(name), kCFStringEncodingUTF8)) continue;
        /* Exclude tunnel/VM interfaces even if manually registered as services. */
        if (strncmp(name, "en", 2) && strcmp(name, "bridge0")) continue;
        CFStringRef key = SCDynamicStoreKeyCreateNetworkInterfaceEntity(
            NULL, kSCDynamicStoreDomainState, bsd, kSCEntNetLink);
        CFPropertyListRef link = key ? SCDynamicStoreCopyValue(store, key) : NULL;
        if (key) CFRelease(key);
        int explicitly_inactive = link && CFGetTypeID(link) == CFDictionaryGetTypeID() &&
            CFEqual(CFDictionaryGetValue((CFDictionaryRef)link, kSCPropNetLinkActive) ?: kCFBooleanTrue,
                    kCFBooleanFalse);
        if (link) CFRelease(link);
        if (explicitly_inactive) continue;
        for (struct ifaddrs *a = addresses; a; a = a->ifa_next) {
            if (strcmp(a->ifa_name, name) || !(a->ifa_flags & IFF_UP) ||
                !(a->ifa_flags & IFF_RUNNING) || (a->ifa_flags & IFF_LOOPBACK)) continue;
            if (!usable_address(a->ifa_addr)) continue;
            if (interface_name && capacity) strlcpy(interface_name, name, capacity);
            result = 1;
            break;
        }
        if (result == 1) break;
    }
    if (services) CFRelease(services);
    freeifaddrs(addresses);
    CFRelease(store);
    CFRelease(prefs);
    return result;
}
