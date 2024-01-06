# DITA-mapref-topichead

## Introduction

By default in DITA, a `<mapref>` includes the referenced submap's contents, but it does not create a new level of navigation hierarchy. This is because the submap title is metdata, and metadata does not contribute to hierarchy.

To create navigation hierarchy for a submap, you could manually wrap the `<mapref>` in a `<topichead>`, but you had to hardcode the `<navtitle>` or use keys and keyscopes to pass the submap title back up to the top-level map:

```
    <topichead>
      <topicmeta>
        <navtitle><ph keyref="book1.BookTitle"/></navtitle>
      </topicmeta>
      <mapref href="book1.ditamap" keyscope="book1"/>
    </topichead>
```

But with this plugin, you can automatically create navigation hierarchy for a submap by including `topichead` in the `@outputclass` attribute value:

```
    <mapref href="book1.ditamap" outputclass="topichead"/>
```

This plugin-based approach has the following advantages:

- The navigation title automatically inherits the submap's title.
- Variables in the submap title are correctly resolved within the submap's scope.

## Getting Started

Install the following provided plugin in your DITA-OT:

```
com.synopsys.mapref-topichead/
```

Note: DITA-OT versions prior to 3.7 do not reliably resolve variables in submap titles.

## Usage

To have a `<mapref>` contribute its own level of navigation hierarchy, include the `topichead` keyword value in its `@outputclass` value:

```
<map>
    <title>Online Help</title>
    <mapref href="book1.ditamap" outputclass="topichead"/>
    <mapref href="book2.ditamap" outputclass="topichead"/>
</map>
```

## Example

The provided example includes two `<bookmap>` files from a top-level `<map>` file.

To run it, install the DITA-OT plugin, then run the following commands:

```
cd ./example
dita --input=olh_top.ditamap --format=html5
```

Without the plugin, the chapters of the two `<bookmap>` files are included as a flat list:

- Chapter 1
- Chapter 2
- Chapter 3
- Chapter 1
- Chapter 2
- Chapter 3

With the plugin, the chapters are grouped by book:

- Book 1 for Product 1
  - Chapter 1
  - Chapter 2
  - Chapter 3
- Book 2 for Product 2
  - Chapter 1
  - Chapter 2
  - Chapter 3

## Implementation Notes

There is a template in

    <dita-ot>/plugins/org.dita.base/xsl/preprocess/maprefImpl.xsl

that reads submap contents into a temporary `<submap>` container element:

```
<submap>
    ...submap contents...
</submap>
```

(The `<submap>` containers keep submap keyscopes separated from each other during preprocessing. They are eventually unwrapped by the `clean-map` task at the end of the preprocessing pipeline.)

This plugin modifies that template so that when `@outputclass` contains the `topichead` keyword, the `<submap>` contents are wrapped in a `<topichead>` element:

```
<topichead>
    <topicmeta>
        <navtitle>...submap title...</navtitle>
    </topicmeta>
    <submap>
        ...submap contents...
    </submap>
</topichead>
```

The navigation title of the `<topichead>` is set to the title of the referenced map. The title comes from `<booktitle>`/`<mainbooktitle>` or `<title>` of the referenced map, whichever is defined.

The following are promoted from the `<submap>` element to the `<topichead>` element, if defined:

- Profiling condition attributes
- `@keyscope` attribute (from the `<mapref>`, the referenced `<map>`, or both)
- `<ditavalref>` element
- `<topicmeta>` child elements (such as `<shortdesc>`)

This plugin post-processes the results of `<xsl:next-match/>`. This approach allows it to work together with other plugins that modify `<mapref>`-processing behaviors.
