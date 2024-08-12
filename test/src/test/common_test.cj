package delegateTest.test

import delegate.property.*

class TestGetterSetterStringDelegate <: ReadWriteProperty<String> {
    var str: String = "def"

    public operator override func ()(property: DelegateProperty): String {
        return str + "@" + property.getValue<String>().getOrThrow()
    }
    public operator override func ()(v: String, property: DelegateProperty) {
        property.setValue<String>(v)
        str = v
    }
}


class TestGetterSetterOptionStringDelegate <: ReadWriteProperty<?String> {
    var str: ?String = "def"

    public operator override func ()(property: DelegateProperty): ?String {
        println((str??"None") + "@" + property.getValue<String>().getOrThrow())
        return (str??"None") + "@" + property.getValue<String>().getOrThrow()
    }
    public operator override func ()(v: ?String, property: DelegateProperty) {
        property.setValue<?String>(v)
        str = v
    }
}


class StringDelegate <: ReadWriteProperty<String> {
    var str: String = ""

    public operator override func ()(property: DelegateProperty): String {
        return str + "@get"
    }
    public operator override func ()(v: String, property: DelegateProperty) {
        str = v + "@set"
    }
}

class StringOptionDelegate <: ReadWriteProperty<?String> {
    var str: ?String = None

    public operator override func ()(property: DelegateProperty): ?String {
        return (str ?? "None") + "@get"
    }
    public operator override func ()(v: ?String, property: DelegateProperty) {
        str = (v ?? "None") + "@set"
    }
}

@Annotation
public class Anno {
    public const init(num:Int) {
        
    }
}